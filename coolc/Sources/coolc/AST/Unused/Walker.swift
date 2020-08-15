//
//  Walker.swift
//
//
//  Created by Jake Foster on 8/11/20.
//
/*
import Foundation

struct Walker: Visitor {
    let listener: Listener

    func walk(program: ProgramNode) {
        visit(program)
    }

    func walk(classNode: ClassNode) {
        visit(classNode)
    }

    private func listenerVisit(_ node: Node) {
        listener.enter(node)
        visitChildren(node)
        listener.exit(node)
    }

    func visit(_ node: ProgramNode) { listenerVisit(node) }
    func visit(_ node: ClassNode) { listenerVisit(node) }
    func visit(_ node: AttributeNode) { listenerVisit(node) }
    func visit(_ node: MethodNode) { listenerVisit(node) }
    func visit(_ node: NoExprNode) { listenerVisit(node) }
    func visit(_ node: BoolExprNode) { listenerVisit(node) }
    func visit(_ node: StringExprNode) { listenerVisit(node) }
    func visit(_ node: IntExprNode) { listenerVisit(node) }
    func visit(_ node: NegateExprNode) { listenerVisit(node) }
    func visit(_ node: IsvoidExprNode) { listenerVisit(node) }
    func visit(_ node: DispatchExprNode) { listenerVisit(node) }
    func visit(_ node: ArithExprNode) { listenerVisit(node) }
    func visit(_ node: CompareExprNode) { listenerVisit(node) }
    func visit(_ node: NotExprNode) { listenerVisit(node) }
    func visit(_ node: AssignExprNode) { listenerVisit(node) }
    func visit(_ node: ObjectExprNode) { listenerVisit(node) }
    func visit(_ node: NewExprNode) { listenerVisit(node) }
    func visit(_ node: ConditionalExprNode) { listenerVisit(node) }
    func visit(_ node: LoopExprNode) { listenerVisit(node) }
    func visit(_ node: CaseExprNode) { listenerVisit(node) }
    func visit(_ node: BlockExprNode) { listenerVisit(node) }
    func visit(_ node: LetExprNode) { listenerVisit(node) }
}
*/
