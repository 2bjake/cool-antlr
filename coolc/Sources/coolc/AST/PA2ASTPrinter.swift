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

    private func printElements(_ strings: CustomStringConvertible...) {
        strings.forEach { print("\(indent)\($0)") }
    }

    private func lineString(_ located: SourceLocated) -> String {
        return "#\(located.location.lineNumber)"
    }

    private func printHeader(_ printable: Printable) {
        printElements(lineString(printable), printable.pa2Name)
    }

    private func printTypeName(_ node: ExprNode) {
        printElements(": _no_type") // TODO: base this on the actual type
    }

    private func printObject(_ printable: Printable, _ internalsPrinter: () -> Void) {
        printHeader(printable)
        indent.inc()
        internalsPrinter()
        indent.dec()
    }

    private func printObject(_ printable: Printable, elements: CustomStringConvertible...) {
        printObject(printable) {
            for element in elements {
                printElements(element)
            }
        }
    }

    private func printNode(_ node: ExprNode, _ internalsPrinter: () -> Void) {
        printObject(node, internalsPrinter)
        printTypeName(node)
    }

    private func printNode(_ node: ExprNode, elements: CustomStringConvertible...) {
        printNode(node) {
            for element in elements {
                printElements(element)
            }
        }
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
        printElements(node.classType, node.parentType, "\"\(node.location.fileName)\"", "(")

        // visit children
        node.features.forEach {
            switch $0 {
                case .attribute(let attr): visit(attr)
                case .method(let method): visit(method)
            }
        }
        printElements(")")
    }

    private func visit(_ node: AttributeNode) {
        printHeader(node)
        indent.inc(); defer { indent.dec() }
        printElements(node.name, node.type, lineString(node))
        // visit children
        visit(node.initBody)
    }

    private func printFormal(_ formal: Formal) {
        printObject(formal, elements: formal.name, formal.type)
    }

    private func visit(_ node: MethodNode) {
        printHeader(node)
        indent.inc(); defer { indent.dec() }
        printElements(node.name)
        node.formals.forEach(printFormal)
        printElements(node.type)
        // visit children
        visit(node.body)
    }

    private func visit(_ node: NoExprNode) {
        printElements(node.pa2Name)
        printTypeName(node)
    }

    private func visit(_ node: BoolExprNode) {
        printNode(node, elements: node.value ? 1 : 0)
    }

    private func visit(_ node: StringExprNode) {
        printNode(node, elements: node.value)
    }

    private func visit(_ node: IntExprNode) {
        printNode(node, elements: node.value)
    }

    private func visit(_ node: NegateExprNode) {
        printNode(node) { visit(node.expr) }
    }

    private func visit(_ node: IsvoidExprNode) {
        printNode(node) { visit(node.expr) }
    }

    private func visit(_ node: DispatchExprNode) {
        printNode(node) {
            visit(node.expr)
            if node.isStaticDispatch { printElements(node.staticClass) }
            printElements(node.methodName, "(")
            node.args.forEach(visit)
            printElements(")")
        }
    }

    private func visit(_ node: ArithExprNode) {
        return printNode(node) {
            visit(node.expr1)
            visit(node.expr2)
        }
    }

    private func visit(_ node: CompareExprNode) {
        return printNode(node) {
            visit(node.expr1)
            visit(node.expr2)
        }
    }

    private func visit(_ node: NotExprNode) {
        printNode(node) { visit(node.expr) }
    }

    private func visit(_ node: AssignExprNode) {
        printNode(node) {
            printElements(node.varName)
            visit(node.expr)
        }
    }

    private func visit(_ node: ObjectExprNode) {
        printNode(node, elements: node.varName)
    }

    private func visit(_ node: NewExprNode) {
        printNode(node, elements: node.newType)
    }

    private func visit(_ node: ConditionalExprNode) {
        printNode(node) {
            visit(node.predExpr)
            visit(node.thenExpr)
            visit(node.elseExpr)
        }
    }

    private func visit(_ node: LoopExprNode) {
        printNode(node) {
            visit(node.predExpr)
            visit(node.body)
        }
    }

    private func printBranch(_ branch: Branch) {
        printObject(branch) {
            printElements(branch.bindName, branch.bindType)
            visit(branch.body)
        }
    }

    private func visit(_ node: CaseExprNode) {
        printNode(node) {
            visit(node.expr)
            node.branches.forEach(printBranch)
        }
    }

    private func visit(_ node: BlockExprNode) {
        printNode(node) {
            node.exprs.forEach(visit)
        }
    }

    private func visit(_ node: LetExprNode) {
        printNode(node) {
            printElements(node.varName, node.varType)
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
