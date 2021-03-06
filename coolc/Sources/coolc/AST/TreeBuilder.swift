//
//  TreeBuilder.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Antlr4
import Foundation

protocol TreeBuilder {
    func build(_ program: CoolParser.ProgramContext) throws -> ProgramNode
}

func makeBuilder(fileName: String) -> TreeBuilder {
    TreeBuilderVisitor(fileName: fileName)
}

// swiftlint:disable force_cast
private class TreeBuilderVisitor: CoolBaseVisitor<Node>, TreeBuilder {

    private let fileName: String
    private var hasError = false

    init(fileName: String) {
        self.fileName = fileName
    }

    private func printError(_ location: String, _ line: Int) {
        hasError = true
        let msg = makeErrorMsg(at: location)
        errPrint("\"\(fileName)\", line \(line): \(msg)")
    }

    private func makeLocation(_ ctx: ParserRuleContext) -> SourceLocation {
        .init(fileName: fileName, lineNumber: ctx.lineNum)
    }

    override func visit(_ tree: ParseTree) -> Node {
        return tree.accept(self) ?? NoExprNode.instance
    }

    private func visitClass(_ tree: ParseTree) -> ClassNode {
        return visit(tree) as! ClassNode
    }

    private func visitExpr(_ tree: ParseTree) -> ExprNode {
        return visit(tree) as! ExprNode
    }

    func build(_ program: CoolParser.ProgramContext) throws -> ProgramNode {
        guard let programNode = visit(program) as? ProgramNode, !hasError else {
            throw CompilerError.parseError
        }
        return programNode
    }

    override func visitProgram(_ ctx: CoolParser.ProgramContext) -> Node {
        guard ctx.getChildCount() > 0 else {
            printError("EOF", 0)
            return NoExprNode()
        }

        let classes = ctx.classDecl().map { visit($0) as! ClassNode }
        return ProgramNode(location: makeLocation(ctx), classes: classes)
    }

    override func visitClassDecl(_ ctx: CoolParser.ClassDeclContext) -> Node {
        let classType = ClassType(ctx.TypeId(0)!.getIdSymbol())
        let parentType = ClassType(ctx.TypeId(1)?.getIdSymbol() ?? .objectTypeName)
        var features = [Feature]()
        ctx.feature().map(visit).forEach {
            switch $0 {
                case let attr as AttributeNode: features.append(.attribute(attr))
                case let method as MethodNode: features.append(.method(method))
                default: fatalError("feature was not method or attribute")
            }
        }
        return ClassNode(location: makeLocation(ctx), classType: classType, parentType: parentType, features: features)

    }

    override func visitMethod(_ ctx: CoolParser.MethodContext) -> Node {
        let type = ClassType(ctx.TypeId()!.getIdSymbol())
        let name = ctx.ObjectId()!.getIdSymbol()
        let formals = ctx.formals()!.formal().map {
            Formal(location: makeLocation($0), type: ClassType($0.TypeId()!.getIdSymbol()), name: $0.ObjectId()!.getIdSymbol())
        }
        let body = visitExpr(ctx.expr()!)
        return MethodNode(location: makeLocation(ctx), type: type, name: name, formals: formals, body: body)
    }

    override func visitAttr(_ ctx: CoolParser.AttrContext) -> Node {
        let type = ClassType(ctx.TypeId()!.getIdSymbol())
        let name = ctx.ObjectId()!.getIdSymbol()
        let initBody = ctx.expr() != nil ? visitExpr(ctx.expr()!) : NoExprNode.instance
        return AttributeNode(location: makeLocation(ctx), type: type, name: name, initBody: initBody)
    }

    override func visitLoop(_ ctx: CoolParser.LoopContext) -> Node {
        let predExpr = visitExpr(ctx.expr(0)!)
        let bodyExpr = visitExpr(ctx.expr(1)!)
        return LoopExprNode(location: makeLocation(ctx), predExpr: predExpr, body: bodyExpr)
    }

    override func visitNot(_ ctx: CoolParser.NotContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        return NotExprNode(location: makeLocation(ctx), expr: expr)
    }

    override func visitBoolConst(_ ctx: CoolParser.BoolConstContext) -> Node {
        let value = ctx.True() != nil
        return BoolExprNode(location: makeLocation(ctx), value: value)
    }

    override func visitStringConst(_ ctx: CoolParser.StringConstContext) -> Node {
        let value = ctx.String()!.getStringSymbol()
        return StringExprNode(location: makeLocation(ctx), value: value)
    }

    override func visitIntConst(_ ctx: CoolParser.IntConstContext) -> Node {
        let value = ctx.Int()!.getIntSymbol()
        return IntExprNode(location: makeLocation(ctx), value: value)
    }

    override func visitBlock(_ ctx: CoolParser.BlockContext) -> Node {
        let exprs = ctx.expr().map(visitExpr)
        return BlockExprNode(location: makeLocation(ctx), exprs: exprs)
    }

    override func visitParens(_ ctx: CoolParser.ParensContext) -> Node? {
        return visitExpr(ctx.expr()!)
    }

    override func visitArith(_ ctx: CoolParser.ArithContext) -> Node {
        let expr1 = visitExpr(ctx.expr(0)!)
        let expr2 = visitExpr(ctx.expr(1)!)
        return ArithExprNode(location: makeLocation(ctx), expr1: expr1, op: ctx.op, expr2: expr2)
    }

    override func visitNegate(_ ctx: CoolParser.NegateContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        return NegateExprNode(location: makeLocation(ctx), expr: expr)
    }

    override func visitObject(_ ctx: CoolParser.ObjectContext) -> Node {
        let varName = ctx.ObjectId()!.getIdSymbol()
        return ObjectExprNode(location: makeLocation(ctx), varName: varName)
    }

    override func visitIsvoid(_ ctx: CoolParser.IsvoidContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        return IsvoidExprNode(location: makeLocation(ctx), expr: expr)
    }

    override func visitCompare(_ ctx: CoolParser.CompareContext) -> Node {
        // check for illegal compare statements like 1 < 2 < 3
        if let comp = ctx.expr().first(where: { $0 is CoolParser.CompareContext}) {
            printError(comp.text, comp.lineNum)
            return NoExprNode()
        }

        let expr1 = visitExpr(ctx.expr(0)!)
        let expr2 = visitExpr(ctx.expr(1)!)

        return CompareExprNode(location: makeLocation(ctx), expr1: expr1, op: ctx.op, expr2: expr2)
    }

    private func buildLetVar(index: Int, _ ctx: CoolParser.LetContext) -> ExprNode {
        if index >= ctx.letvar().count {
            return visitExpr(ctx.expr()!)
        } else {
            let letvar = ctx.letvar()[index]
            let varName = letvar.ObjectId()!.getIdSymbol()
            let varType = ClassType(letvar.TypeId()!.getIdSymbol())
            let initExpr = letvar.expr() == nil ? NoExprNode.instance : visitExpr(letvar.expr()!)
            let bodyExpr = buildLetVar(index: index + 1, ctx)
            return LetExprNode(location: makeLocation(ctx), varName: varName, varType: varType, initExpr: initExpr, bodyExpr: bodyExpr)
        }
    }

    override func visitLet(_ ctx: CoolParser.LetContext) -> Node {
        return buildLetVar(index: 0, ctx)
    }

    override func visitAssign(_ ctx: CoolParser.AssignContext) -> Node {
        let varName = ctx.ObjectId()!.getIdSymbol()
        let expr = ctx.expr() != nil ? visitExpr(ctx.expr()!) : NoExprNode.instance
        return AssignExprNode(location: makeLocation(ctx), varName: varName, expr: expr)
    }

    override func visitConditional(_ ctx: CoolParser.ConditionalContext) -> Node {
        let predExpr = visitExpr(ctx.expr(0)!)
        let thenExpr = visitExpr(ctx.expr(1)!)
        let elseExpr = visitExpr(ctx.expr(2)!)
        return ConditionalExprNode(location: makeLocation(ctx), predExpr: predExpr, thenExpr: thenExpr, elseExpr: elseExpr)
    }

    override func visitNew(_ ctx: CoolParser.NewContext) -> Node {
        let type = ClassType(ctx.TypeId()!.getIdSymbol())
        return NewExprNode(location: makeLocation(ctx), newType: type)
    }

    override func visitDispatch(_ ctx: CoolParser.DispatchContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        let methodName = ctx.ObjectId()!.getIdSymbol()
        let args = ctx.args()?.expr().map(visitExpr) ?? []

        return DispatchExprNode(location: makeLocation(ctx), expr: expr, staticClass: .none, methodName: methodName, args: args)
    }

    override func visitSelfDispatch(_ ctx: CoolParser.SelfDispatchContext) -> Node {
        let location = makeLocation(ctx)
        let expr = ObjectExprNode(location: location, varName: .selfName)
        let methodName = ctx.ObjectId()!.getIdSymbol()
        let args = ctx.args()?.expr().map(visitExpr) ?? []

        return DispatchExprNode(location: location, expr: expr, staticClass: .none, methodName: methodName, args: args)
    }

    override func visitStaticDispatch(_ ctx: CoolParser.StaticDispatchContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        let staticClass = ClassType(ctx.TypeId()!.getIdSymbol())
        let methodName = ctx.ObjectId()!.getIdSymbol()
        let args = ctx.args()?.expr().map(visitExpr) ?? []

        return DispatchExprNode(location: makeLocation(ctx), expr: expr, staticClass: staticClass, methodName: methodName, args: args)
    }

    override func visitCase(_ ctx: CoolParser.CaseContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        let branches: [Branch] = ctx.branch().map {
            let bindName = $0.ObjectId()!.getIdSymbol()
            let bindType = ClassType($0.TypeId()!.getIdSymbol())
            let body = visitExpr($0.expr()!)
            return Branch(location: makeLocation($0), bindName: bindName, bindType: bindType, body: body)
        }
        return CaseExprNode(location: makeLocation(ctx), expr: expr, branches: branches)
    }
}
