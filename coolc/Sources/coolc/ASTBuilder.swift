//
//  ASTBuilder.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Antlr4
import Foundation

class ASTBuilder: CoolBaseVisitor<Node> {

    let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    private func makeLocation(_ ctx: ParserRuleContext) -> SourceLocation {
        .init(fileName: fileName, lineNumber: ctx.lineNum)
    }

    override func visit(_ tree: ParseTree) -> Node {
        return tree.accept(self) ?? NoExprNode.instance
    }

    func visitClass(_ tree: ParseTree) -> ClassNode {
        return visit(tree) as! ClassNode
    }

    func visitExpr(_ tree: ParseTree) -> ExprNode {
        return visit(tree) as! ExprNode
    }

    override func visitProgram(_ ctx: CoolParser.ProgramContext) -> Node {
        let classes = ctx.classDecl().map(visitClass)
        return ProgramNode(location: makeLocation(ctx), classes: classes)
    }

    override func visitClassDecl(_ ctx: CoolParser.ClassDeclContext) -> Node {
        let classType = ClassType(ctx.TypeId(0)!.getText())
        let parentType = ClassType(ctx.TypeId(1)?.getText() ?? Symbols.objectTypeName)
        var methods = [MethodNode]()
        var attributes = [AttributeNode]()
        ctx.feature().map(visit).forEach {
            switch $0 {
                case let attr as AttributeNode: attributes.append(attr)
                case let method as MethodNode: methods.append(method)
                default: fatalError("feature was not method or attribute")
            }
        }
        return ClassNode(location: makeLocation(ctx), classType: classType, parentType: parentType, methods: methods, attributes: attributes)

    }

    override func visitMethod(_ ctx: CoolParser.MethodContext) -> Node {
        let type = ClassType(ctx.TypeId()!.getText())
        let name = ctx.ObjectId()!.getText()
        let formals = ctx.formals()!.formal().map {
            Formal(location: makeLocation($0), type: ClassType($0.TypeId()!.getText()), name: $0.ObjectId()!.getText())
        }
        let body = visitExpr(ctx.expr()!)
        return MethodNode(location: makeLocation(ctx), type: type, name: name, formals: formals, body: body)
    }

    override func visitAttr(_ ctx: CoolParser.AttrContext) -> Node {
        let type = ClassType(ctx.TypeId()!.getText())
        let name = ctx.ObjectId()!.getText()
        let initBody = visitExpr(ctx.expr()!)
        return AttributeNode(location: makeLocation(ctx), type: type, name: name, initBody: initBody)
    }

    override func visitLoop(_ ctx: CoolParser.LoopContext) -> Node {
        let predExpr = visitExpr(ctx.expr(0)!)
        let bodyExpr = visitExpr(ctx.expr(1)!)
        return LoopExpr(location: makeLocation(ctx), predExpr: predExpr, body: bodyExpr)
    }

    override func visitNot(_ ctx: CoolParser.NotContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        return NotExpr(location: makeLocation(ctx), expr: expr)
    }

    override func visitBoolConst(_ ctx: CoolParser.BoolConstContext) -> Node {
        let value = ctx.True() != nil
        return ConstantExpr<Bool>(location: makeLocation(ctx), value: value)
    }

    override func visitStringConst(_ ctx: CoolParser.StringConstContext) -> Node {
        let value = ctx.String()!.getText()
        return ConstantExpr<String>(location: makeLocation(ctx), value: value)
    }

    override func visitIntConst(_ ctx: CoolParser.IntConstContext) -> Node {
        let value = Int(ctx.Int()!.getText())!
        return ConstantExpr<Int>(location: makeLocation(ctx), value: value)
    }

    override func visitBlock(_ ctx: CoolParser.BlockContext) -> Node {
        let exprs = ctx.expr().map(visitExpr)
        return BlockExpr(location: makeLocation(ctx), exprs: exprs)
    }

    override func visitArith(_ ctx: CoolParser.ArithContext) -> Node {
        let expr1 = visitExpr(ctx.expr(0)!)
        let expr2 = visitExpr(ctx.expr(1)!)
        return ArithExpr(location: makeLocation(ctx), expr1: expr1, op: ctx.op, expr2: expr2)
    }

    override func visitNegate(_ ctx: CoolParser.NegateContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        return NegateExpr(location: makeLocation(ctx), expr: expr)
    }

    override func visitObject(_ ctx: CoolParser.ObjectContext) -> Node {
        let varName = ctx.ObjectId()!.getText()
        return ObjectExpr(location: makeLocation(ctx), varName: varName)
    }

    override func visitIsvoid(_ ctx: CoolParser.IsvoidContext) -> Node {
        let expr = visitExpr(ctx.expr()!)
        return IsvoidExpr(location: makeLocation(ctx), expr: expr)
    }

    override func visitCompare(_ ctx: CoolParser.CompareContext) -> Node {
        let expr1 = visitExpr(ctx.expr(0)!)
        let expr2 = visitExpr(ctx.expr(1)!)
        return CompareExpr(location: makeLocation(ctx), expr1: expr1, op: ctx.op, expr2: expr2)
    }

    private func buildLetVar(index: Int, _ ctx: CoolParser.LetContext) -> ExprNode {
        if index >= ctx.letvar().count {
            return visitExpr(ctx.expr()!)
        } else {
            let letvar = ctx.letvar()[index]
            let varName = letvar.ObjectId()!.getText()
            let varType = ClassType(letvar.TypeId()!.getText())
            let initExpr = letvar.expr() == nil ? NoExprNode.instance : visitExpr(letvar.expr()!)
            let bodyExpr = buildLetVar(index: index + 1, ctx)
            return LetExpr(location: makeLocation(ctx), varName: varName, varType: varType, initExpr: initExpr, bodyExpr: bodyExpr)
        }
    }

    override func visitLet(_ ctx: CoolParser.LetContext) -> Node {
        return buildLetVar(index: 0, ctx)
    }

    override func visitAssign(_ ctx: CoolParser.AssignContext) -> Node {
        let varName = ctx.ObjectId()!.getText()
        let expr = visitExpr(ctx.expr()!)
        return AssignExpr(location: makeLocation(ctx), varName: varName, expr: expr)
    }
}

