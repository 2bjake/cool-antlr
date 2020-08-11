//
//  ASTWalker.swift
//
//
//  Created by Jake Foster on 8/11/20.
//

import Foundation

struct ASTWalker: ASTVisitor {
    func walk(ast: ProgramNode) {
        visit(ast)
    }

    func enterAction(_ node: Node) {
        print("enter ", node.pa2Name)
    }

    func exitAction(_ node: Node) {
        print("exit  ", node.pa2Name)
    }

    func visitWithActions(_ node: Node) {
        enterAction(node)
        visitChildren(node)
        exitAction(node)
    }

    func visit(_ node: ProgramNode) { visitWithActions(node) }
    func visit(_ node: ClassNode) { visitWithActions(node) }
    func visit(_ node: AttributeNode) { visitWithActions(node) }
    func visit(_ node: MethodNode) { visitWithActions(node) }
    func visit(_ node: NoExprNode) { visitWithActions(node) }
    func visit(_ node: BoolExprNode) { visitWithActions(node) }
    func visit(_ node: StringExprNode) { visitWithActions(node) }
    func visit(_ node: IntExprNode) { visitWithActions(node) }
    func visit(_ node: NegateExprNode) { visitWithActions(node) }
    func visit(_ node: IsvoidExprNode) { visitWithActions(node) }
    func visit(_ node: DispatchExprNode) { visitWithActions(node) }
    func visit(_ node: ArithExprNode) { visitWithActions(node) }
    func visit(_ node: CompareExprNode) { visitWithActions(node) }
    func visit(_ node: NotExprNode) { visitWithActions(node) }
    func visit(_ node: AssignExprNode) { visitWithActions(node) }
    func visit(_ node: ObjectExprNode) { visitWithActions(node) }
    func visit(_ node: NewExprNode) { visitWithActions(node) }
    func visit(_ node: ConditionalExprNode) { visitWithActions(node) }
    func visit(_ node: LoopExprNode) { visitWithActions(node) }
    func visit(_ node: CaseExprNode) { visitWithActions(node) }
    func visit(_ node: BlockExprNode) { visitWithActions(node) }
    func visit(_ node: LetExprNode) { visitWithActions(node) }
}
