//
//  ASTPrinter.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Foundation

// prints the AST in the format that PA2 grading scripts expect
class PA2ASTPrinter {
    private var indent = PA2Indention()

    private typealias Printable = PA2Named & SourceLocated

    private func printDetails(_ strings: CustomStringConvertible...) {
        strings.forEach { print("\(indent)\($0)") }
    }

    private func printHeader(_ node: Printable) {
        printDetails("#\(node.location.lineNumber)", node.pa2Name)
    }

    private func printType(_ node: ExprNode) {
        print("\(indent): _no_type") // TODO: base this on the actual type
    }

    private func printInternals(_ printable: Printable, _ internals: () -> Void) {
        printHeader(printable)
        indent.inc()
        internals()
        indent.dec()
    }

    private func printInternals(_ printable: Printable, details: CustomStringConvertible...) {
        printInternals(printable) {
            for detail in details {
                printDetails(detail)
            }
        }
    }

    private func printInternals(_ node: ExprNode, _ internals: () -> Void) {
        printHeader(node)
        indent.inc()
        internals()
        indent.dec()
        printType(node)
    }

    private func printInternals(_ node: ExprNode, details: CustomStringConvertible...) {
        printInternals(node) {
            for detail in details {
                printDetails(detail)
            }
        }
    }

    private func lineString(_ node: SourceLocated) -> String {
        return "#\(node.location.lineNumber)"
    }

    private func visit(_ node: ProgramNode) {
        printHeader(node)
        indent.inc(); defer { indent.dec() }
        // visit children
        node.classes.forEach(visit)
    }

    private func visit(_ node: ClassNode) {
        printHeader(node)
        indent.inc(); defer { indent.dec() }
        printDetails(node.classType, node.parentType, "\"\(node.location.fileName)\"", "(")

        // visit children
        node.features.forEach {
            switch $0 {
                case .attribute(let attr): visit(attr)
                case .method(let method): visit(method)
            }
        }
        printDetails(")")
    }

    private func visit(_ node: AttributeNode) {
        printHeader(node)
        indent.inc(); defer { indent.dec() }
        printDetails(node.name, node.type, lineString(node))
        // visit children
        visit(node.initBody)
    }

    private func printFormal(_ formal: Formal) {
        printInternals(formal, details: formal.name, formal.type)
    }

    private func visit(_ node: MethodNode) {
        printHeader(node)
        indent.inc(); defer { indent.dec() }
        printDetails(node.name)
        node.formals.forEach(printFormal)
        printDetails(node.type)
        // visit children
        visit(node.body)
    }

    private func visit(_ node: NoExprNode) {
        printDetails(node.pa2Name)
        printType(node)
    }

    private func visit(_ node: BoolExprNode) {
        printInternals(node, details: node.value ? 1 : 0)
    }

    private func visit(_ node: StringExprNode) {
        printInternals(node, details: node.value)
    }

    private func visit(_ node: IntExprNode) {
        printInternals(node, details: node.value)
    }

    private func visit(_ node: NegateExprNode) {
        printInternals(node) { visit(node.expr) }
    }

    private func visit(_ node: IsvoidExprNode) {
        printInternals(node) { visit(node.expr) }
    }

    private func visit(_ node: DispatchExprNode) {
        printInternals(node) {
            visit(node.expr)
            if node.isStaticDispatch { printDetails(node.staticClass) }
            printDetails(node.methodName, "(")
            node.args.forEach(visit)
            printDetails(")")
        }
    }

    private func visit(_ node: ArithExprNode) {
        return printInternals(node) {
            visit(node.expr1)
            visit(node.expr2)
        }
    }

    private func visit(_ node: CompareExprNode) {
        return printInternals(node) {
            visit(node.expr1)
            visit(node.expr2)
        }
    }

    private func visit(_ node: NotExprNode) {
        printInternals(node) { visit(node.expr) }
    }

    private func visit(_ node: AssignExprNode) {
        printInternals(node) {
            printDetails(node.varName)
            visit(node.expr)
        }
    }

    private func visit(_ node: ObjectExprNode) {
        printInternals(node, details: node.varName)
    }

    private func visit(_ node: NewExprNode) {
        printInternals(node, details: node.newType)
    }

    private func visit(_ node: ConditionalExprNode) {
        printInternals(node) {
            visit(node.predExpr)
            visit(node.thenExpr)
            visit(node.elseExpr)
        }
    }

    private func visit(_ node: LoopExprNode) {
        printInternals(node) {
            visit(node.predExpr)
            visit(node.body)
        }
    }

    private func printBranch(_ branch: Branch) {
        printInternals(branch) {
            printDetails(branch.bindName, branch.bindType)
            visit(branch.body)
        }
    }

    private func visit(_ node: CaseExprNode) {
        printInternals(node) {
            visit(node.expr)
            node.branches.forEach(printBranch)
        }
    }

    private func visit(_ node: BlockExprNode) {
        printInternals(node) {
            node.exprs.forEach(visit)
        }
    }

    private func visit(_ node: LetExprNode) {
        printInternals(node) {
            printDetails(node.varName, node.varType)
            visit(node.initExpr)
            visit(node.bodyExpr)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func visit(_ node: ExprNode) {
        switch node {
            case let node as LoopExprNode: visit(node)
            case let node as NotExprNode: visit(node)
            case let node as BoolExprNode: visit(node)
            case let node as StringExprNode: visit(node)
            case let node as IntExprNode: visit(node)
            case let node as BlockExprNode: visit(node)
            case let node as NegateExprNode: visit(node)
            case let node as ObjectExprNode: visit(node)
            case let node as IsvoidExprNode: visit(node)
            case let node as LetExprNode: visit(node)
            case let node as AssignExprNode: visit(node)
            case let node as ConditionalExprNode: visit(node)
            case let node as NewExprNode: visit(node)
            case let node as DispatchExprNode: visit(node)
            case let node as CaseExprNode: visit(node)
            case let node as ArithExprNode: visit(node)
            case let node as CompareExprNode: visit(node)
            case let node as NoExprNode: visit(node)
            default: fatalError()
        }
    }

    func printTree(_ node: ProgramNode) {
        visit(node)
    }
}
