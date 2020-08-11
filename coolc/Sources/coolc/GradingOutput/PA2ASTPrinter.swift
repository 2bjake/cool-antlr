//
//  ASTPrinter.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Foundation

// prints the AST in the format that PA2 grading scripts expect
class PA2ASTPrinter: ASTVisitor {
    private let printer = PA2Printer()

    func printTree(_ node: ProgramNode) {
        visit(node)
    }

    private func printNodeWithChildren(_ node: ExprNode, elements: CustomStringConvertible...) {
        printer.printNode(node) {
            for element in elements {
                printer.printElements(element)
            }
            visitChildren(node)
        }
    }

    func visit(_ node: ProgramNode) {
        printer.printObject(node) { visitChildren(node) }
    }

    func visit(_ node: ClassNode) {
        printer.printObject(node) {
            printer.printElements(node.classType, node.parentType, "\"\(node.location.fileName)\"", "(")
            visitChildren(node)
            printer.printElements(")")
        }
    }

    func visit(_ node: AttributeNode) {
        printer.printObject(node) {
            printer.printElements(node.name, node.type, PA2Printer.lineString(node))
            visitChildren(node)
        }
    }

    private func printFormal(_ formal: Formal) {
        printer.printObject(formal, elements: formal.name, formal.type)
    }

    func visit(_ node: MethodNode) {
        printer.printObject(node) {
            printer.printElements(node.name)
            node.formals.forEach(printFormal)
            printer.printElements(node.type)
            visitChildren(node)
        }
    }

    func visit(_ node: NoExprNode) {
        printer.printElements(node.pa2Name)
        printer.printTypeName(node)
    }

    func visit(_ node: BoolExprNode) {
        printer.printNode(node, elements: node.value ? 1 : 0)
    }

    func visit(_ node: StringExprNode) {
        printer.printNode(node, elements: node.value)
    }

    func visit(_ node: IntExprNode) {
        printer.printNode(node, elements: node.value)
    }

    func visit(_ node: NegateExprNode) {
        printNodeWithChildren(node)
    }

    func visit(_ node: IsvoidExprNode) {
        printNodeWithChildren(node)
    }

    func visit(_ node: DispatchExprNode) {
        printer.printNode(node) {
            visit(node.expr)
            if node.isStaticDispatch { printer.printElements(node.staticClass) }
            printer.printElements(node.methodName, "(")
            node.args.forEach(visit)
            printer.printElements(")")
        }
    }

    func visit(_ node: ArithExprNode) {
        printNodeWithChildren(node)
    }

    func visit(_ node: CompareExprNode) {
        printNodeWithChildren(node)
    }

    func visit(_ node: NotExprNode) {
        printNodeWithChildren(node)
    }

    func visit(_ node: AssignExprNode) {
        printNodeWithChildren(node, elements: node.varName)
    }

    func visit(_ node: ObjectExprNode) {
        printer.printNode(node, elements: node.varName)
    }

    func visit(_ node: NewExprNode) {
        printer.printNode(node, elements: node.newType)
    }

    func visit(_ node: ConditionalExprNode) {
        printNodeWithChildren(node)
    }

    func visit(_ node: LoopExprNode) {
        printNodeWithChildren(node)
    }

    private func printBranch(_ branch: Branch) {
        printer.printObject(branch) {
            printer.printElements(branch.bindName, branch.bindType)
            visit(branch.body)
        }
    }

    func visit(_ node: CaseExprNode) {
        printer.printNode(node) {
            visit(node.expr)
            node.branches.forEach(printBranch)
        }
    }

    func visit(_ node: BlockExprNode) {
        printNodeWithChildren(node)
    }

    func visit(_ node: LetExprNode) {
        printNodeWithChildren(node, elements: node.varName, node.varType)
    }
}
