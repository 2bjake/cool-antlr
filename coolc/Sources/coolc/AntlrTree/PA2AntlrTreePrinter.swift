//
//  AntlrTreePrinter.swift
//
//
//  Created by Jake Foster on 8/7/20.
//

import Antlr4
import Foundation

private extension ParserRuleContext {
    var name: String {
        switch self {
            case is CoolParser.ProgramContext: return "_program"
            case is CoolParser.ClassDeclContext: return "_class"
            case is CoolParser.AttrContext: return "_attr"
            case is CoolParser.MethodContext: return "_method"
            case is CoolParser.LoopContext: return "_loop"
            case is CoolParser.NotContext: return "_comp"
            case is CoolParser.BoolConstContext: return "_bool"
            case is CoolParser.StringConstContext: return "_string"
            case is CoolParser.IntConstContext: return "_int"
            case is CoolParser.BlockContext: return "_block"
            case is CoolParser.NegateContext: return "_neg"
            case is CoolParser.ObjectContext: return "_object"
            case is CoolParser.IsvoidContext: return "_isvoid"
            case is CoolParser.LetContext: return "_let"
            case is CoolParser.AssignContext: return "_assign"
            case is CoolParser.ConditionalContext: return "_cond"
            case is CoolParser.NewContext: return "_new"
            case is CoolParser.DispatchContext: return "_dispatch"
            case is CoolParser.SelfDispatchContext: return "_dispatch"
            case is CoolParser.StaticDispatchContext: return "_static_dispatch"
            case is CoolParser.CaseContext: return "_typcase"
            case is CoolParser.BranchContext: return "_branch"
            case is CoolParser.FormalContext: return "_formal"
            case let arith as CoolParser.ArithContext: return arith.op.pa2Name
            case let comp as CoolParser.CompareContext: return comp.op.pa2Name
            default: return "unknown"
        }
    }

    var lineString: String {
        return "#\(lineNum)"
    }
}

// prints Antlr tree in form that PA2 expects
class PA2AntlrTreePrinter: CoolBaseVisitor<Void> {
    var indent = PA2Indention()
    let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    func printHeader(_ ctx: ParserRuleContext) {
        print("\(indent)\(ctx.lineString)")
        print("\(indent)\(ctx.name)")
    }

    func printDetails(_ strings: CustomStringConvertible...) {
        strings.forEach { print("\(indent)\($0)") }
    }

    func printType() {
        print("\(indent): _no_type")
    }

    func printInternals(ctx: ParserRuleContext, shouldPrintType: Bool = true, _ internals: () -> Void) {
        printHeader(ctx)
        indent.inc()
        internals()
        indent.dec()
        if shouldPrintType {
            printType()
        }
    }

    func printNoExpr() {
        printDetails("_no_expr")
        printType()
    }

    override func visitProgram(_ ctx: CoolParser.ProgramContext) -> Void? {
        printHeader(ctx)
        indent.inc(); defer { indent.dec() }
        return visitChildren(ctx)
    }

    override func visitClassDecl(_ ctx: CoolParser.ClassDeclContext) -> Void? {
        printHeader(ctx)
        indent.inc(); defer { indent.dec() }
        printDetails(ctx.classTypeName, ctx.parentTypeName, "\"\(fileName)\"", "(")
        visitChildren(ctx)
        printDetails(")")
        return ()
    }

    override func visitAttr(_ ctx: CoolParser.AttrContext) -> Void? {
        printHeader(ctx)
        indent.inc(); defer { indent.dec() }
        printDetails(ctx.ObjectId()!, ctx.TypeId()!, ctx.lineString)
        if ctx.expr() == nil { printNoExpr() }
        return visitChildren(ctx)
    }

    override func visitMethod(_ ctx: CoolParser.MethodContext) -> Void? {
        printHeader(ctx)
        indent.inc(); defer { indent.dec() }
        printDetails(ctx.ObjectId()!)

        visit(ctx.formals()!)
        printDetails(ctx.TypeId()!)
        visit(ctx.expr()!)
        return ()
    }

    override func visitFormal(_ ctx: CoolParser.FormalContext) -> Void? {
        return printInternals(ctx: ctx, shouldPrintType: false) {
            printDetails(ctx.ObjectId()!, ctx.TypeId()!)
        }
    }

    override func visitLoop(_ ctx: CoolParser.LoopContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    override func visitNot(_ ctx: CoolParser.NotContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    override func visitBoolConst(_ ctx: CoolParser.BoolConstContext) -> Void? {
        return printInternals(ctx: ctx) {
            ctx.False() == nil ? printDetails(1) : printDetails(0)
        }
    }

    override func visitStringConst(_ ctx: CoolParser.StringConstContext) -> Void? {
        return printInternals(ctx: ctx) { printDetails(ctx.String()!) }
    }

    override func visitIntConst(_ ctx: CoolParser.IntConstContext) -> Void? {
        return printInternals(ctx: ctx) { printDetails(ctx.Int()!) }
    }

    override func visitBlock(_ ctx: CoolParser.BlockContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    override func visitArith(_ ctx: CoolParser.ArithContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    override func visitNegate(_ ctx: CoolParser.NegateContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    override func visitObject(_ ctx: CoolParser.ObjectContext) -> Void? {
        return printInternals(ctx: ctx) { printDetails(ctx.ObjectId()!) }
    }

    override func visitIsvoid(_ ctx: CoolParser.IsvoidContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    override func visitCompare(_ ctx: CoolParser.CompareContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    private func printLetVar(index: Int, _ ctx: CoolParser.LetContext) {
        if index >= ctx.letvar().count {
            visit(ctx.expr()!)
        } else {
            let letvar = ctx.letvar()[index]
            printHeader(ctx)
            indent.inc()
            printDetails(letvar.ObjectId()!, letvar.TypeId()!)
            if letvar.expr() == nil {
                printNoExpr()
            } else {
                visit(letvar.expr()!)
            }
            printLetVar(index: index + 1, ctx)
            indent.dec()
            printType()
        }
    }

    override func visitLet(_ ctx: CoolParser.LetContext) -> Void? {
        printLetVar(index: 0, ctx)
    }

    override func visitAssign(_ ctx: CoolParser.AssignContext) -> Void? {
        return printInternals(ctx: ctx) {
            printDetails(ctx.ObjectId()!)
            visitChildren(ctx)
        }
    }

    override func visitConditional(_ ctx: CoolParser.ConditionalContext) -> Void? {
        return printInternals(ctx: ctx) { visitChildren(ctx) }
    }

    override func visitNew(_ ctx: CoolParser.NewContext) -> Void? {
        return printInternals(ctx: ctx) {
            printDetails(ctx.TypeId()!)
            visitChildren(ctx)
        }
    }

    override func visitDispatch(_ ctx: CoolParser.DispatchContext) -> Void? {
        return printInternals(ctx: ctx) {
            visit(ctx.expr()!)
            printDetails(ctx.ObjectId()!, "(")
            if let args = ctx.args() {
                visit(args)
            }
            printDetails(")")
        }
    }

    override func visitSelfDispatch(_ ctx: CoolParser.SelfDispatchContext) -> Void? {
        return printInternals(ctx: ctx) {
            // TODO: faking self object for now, figure out how to actually insert such an object in the tree...
            print("\(indent)\(ctx.lineString)")
            print("\(indent)_object")
            indent.inc()
            printDetails("self")
            printType()
            // end fake self object

            printDetails(ctx.ObjectId()!, "(")
            if let args = ctx.args() {
                visit(args)
            }
            printDetails(")")
        }
    }

    override func visitStaticDispatch(_ ctx: CoolParser.StaticDispatchContext) -> Void? {
        return printInternals(ctx: ctx) {
            visit(ctx.expr()!)
            printDetails(ctx.TypeId()!, ctx.ObjectId()!, "(")
            if let args = ctx.args() {
                visit(args)
            }
            printDetails(")")
        }
    }

    override func visitCase(_ ctx: CoolParser.CaseContext) -> Void? {
        return printInternals(ctx: ctx) {
            visitChildren(ctx)
        }
    }

    override func visitBranch(_ ctx: CoolParser.BranchContext) -> Void? {
        return printInternals(ctx: ctx, shouldPrintType: false) {
            printDetails(ctx.ObjectId()!, ctx.TypeId()!)
            visitChildren(ctx)
        }
    }
}
