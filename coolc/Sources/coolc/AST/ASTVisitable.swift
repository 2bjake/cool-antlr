//
//  ASTVisitable.swift
//
//
//  Created by Jake Foster on 8/11/20.
//

protocol ASTVisitable {
    func accept(_ visitor: ASTVisitor)
    var children: [Node] { get }
}

extension Node {
    func accept(_ visitor: ASTVisitor) {
        visitor.visit(self)
    }
}

extension ProgramNode {
    var children: [Node] { classes }
}

extension ClassNode {
    var children: [Node] {
        features.map {
            switch $0 {
                case .attribute(let node): return node
                case .method(let node): return node
            }
        }
    }
}

extension AttributeNode {
    var children: [Node] { [initBody] }
}

extension MethodNode {
    var children: [Node] { [body] }
}

extension LoopExprNode {
    var children: [Node] { [predExpr, body] }
}

extension NotExprNode {
    var children: [Node] { [expr] }
}

extension BoolExprNode {
    var children: [Node] { [] }
}

extension StringExprNode {
    var children: [Node] { [] }
}

extension IntExprNode {
    var children: [Node] { [] }
}

extension BlockExprNode {
    var children: [Node] { exprs }
}

extension NegateExprNode {
    var children: [Node] { [expr] }
}

extension ObjectExprNode {
    var children: [Node] { [] }
}

extension IsvoidExprNode {
    var children: [Node] { [expr] }
}

extension LetExprNode {
    var children: [Node] { [initExpr, bodyExpr] }
}

extension AssignExprNode {
    var children: [Node] { [expr] }
}

extension ConditionalExprNode {
    var children: [Node] { [predExpr, thenExpr, elseExpr] }
}

extension NewExprNode {
    var children: [Node] { [] }
}

extension DispatchExprNode {
    var children: [Node] { [expr] + args }
}

extension CaseExprNode {
    var children: [Node] { [expr] }
}

extension ArithExprNode {
    var children: [Node] { [expr1, expr2] }
}

extension CompareExprNode {
    var children: [Node] { [expr1, expr2] }
}

extension NoExprNode {
    var children: [Node] { [] }
}
