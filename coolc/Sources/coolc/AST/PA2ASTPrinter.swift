//
//  ASTPrinter.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Foundation

// prints the AST in the format that PA2 grading scripts expect
class PA2ASTPrinter {
    private let printer = PA2Printer()

    func printTree(_ node: ProgramNode) {
        visit(node)
    }

    private func visit(_ node: ProgramNode) {
        printer.printObject(node) {
            node.classes.forEach(visit)
        }
    }

    private func visit(_ node: ClassNode) {
        printer.printObject(node) {
            printer.printElements(node.classType, node.parentType, "\"\(node.location.fileName)\"", "(")
            node.features.forEach {
                switch $0 {
                    case .attribute(let attr): visit(attr)
                    case .method(let method): visit(method)
                }
            }
            printer.printElements(")")
        }
    }

    private func visit(_ node: AttributeNode) {
        printer.printObject(node) {
            printer.printElements(node.name, node.type, PA2Printer.lineString(node))
            visit(node.initBody)
        }
    }

    private func printFormal(_ formal: Formal) {
        printer.printObject(formal, elements: formal.name, formal.type)
    }

    private func visit(_ node: MethodNode) {
        printer.printObject(node) {
            printer.printElements(node.name)
            node.formals.forEach(printFormal)
            printer.printElements(node.type)
            visit(node.body)
        }
    }

    private func visit(_ node: NoExprNode) {
        printer.printElements(node.pa2Name)
        printer.printTypeName(node)
    }

    private func visit(_ node: BoolExprNode) {
        printer.printNode(node, elements: node.value ? 1 : 0)
    }

    private func visit(_ node: StringExprNode) {
        printer.printNode(node, elements: node.value)
    }

    private func visit(_ node: IntExprNode) {
        printer.printNode(node, elements: node.value)
    }

    private func visit(_ node: NegateExprNode) {
        printer.printNode(node) { visit(node.expr) }
    }

    private func visit(_ node: IsvoidExprNode) {
        printer.printNode(node) { visit(node.expr) }
    }

    private func visit(_ node: DispatchExprNode) {
        printer.printNode(node) {
            visit(node.expr)
            if node.isStaticDispatch { printer.printElements(node.staticClass) }
            printer.printElements(node.methodName, "(")
            node.args.forEach(visit)
            printer.printElements(")")
        }
    }

    private func visit(_ node: ArithExprNode) {
        return printer.printNode(node) {
            visit(node.expr1)
            visit(node.expr2)
        }
    }

    private func visit(_ node: CompareExprNode) {
        return printer.printNode(node) {
            visit(node.expr1)
            visit(node.expr2)
        }
    }

    private func visit(_ node: NotExprNode) {
        printer.printNode(node) { visit(node.expr) }
    }

    private func visit(_ node: AssignExprNode) {
        printer.printNode(node) {
            printer.printElements(node.varName)
            visit(node.expr)
        }
    }

    private func visit(_ node: ObjectExprNode) {
        printer.printNode(node, elements: node.varName)
    }

    private func visit(_ node: NewExprNode) {
        printer.printNode(node, elements: node.newType)
    }

    private func visit(_ node: ConditionalExprNode) {
        printer.printNode(node) {
            visit(node.predExpr)
            visit(node.thenExpr)
            visit(node.elseExpr)
        }
    }

    private func visit(_ node: LoopExprNode) {
        printer.printNode(node) {
            visit(node.predExpr)
            visit(node.body)
        }
    }

    private func printBranch(_ branch: Branch) {
        printer.printObject(branch) {
            printer.printElements(branch.bindName, branch.bindType)
            visit(branch.body)
        }
    }

    private func visit(_ node: CaseExprNode) {
        printer.printNode(node) {
            visit(node.expr)
            node.branches.forEach(printBranch)
        }
    }

    private func visit(_ node: BlockExprNode) {
        printer.printNode(node) {
            node.exprs.forEach(visit)
        }
    }

    private func visit(_ node: LetExprNode) {
        printer.printNode(node) {
            printer.printElements(node.varName, node.varType)
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
}
