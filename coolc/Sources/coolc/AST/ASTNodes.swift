//
//  Nodes.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Foundation

struct SourceLocation {
    let fileName: String
    let lineNumber: Int
}

protocol SourceLocated {
    var location: SourceLocation { get }
}

protocol Node: SourceLocated, PA2Named, ASTVisitable {}

struct ProgramNode: Node {
    let location: SourceLocation
    private(set) var classes: [ClassNode]

    mutating func addClasses(_ classNodes: [ClassNode]) {
        classes.append(contentsOf: classNodes)
    }
}

enum Feature {
    case method(MethodNode)
    case attribute(AttributeNode)
}

struct ClassNode: Node {
    let location: SourceLocation
    let classType: ClassType
    let parentType: ClassType
    let features: [Feature]
//    let methods: [MethodNode]
//    let attributes: [AttributeNode]
}

struct Formal: SourceLocated {
    let location: SourceLocation
    let type: ClassType
    let name: IdSymbol
}

struct MethodNode: Node {
    let location: SourceLocation
    let type: ClassType
    let name: IdSymbol
    let formals: [Formal]
    let body: ExprNode
}

struct AttributeNode: Node {
    let location: SourceLocation
    let type: ClassType
    let name: IdSymbol
    let initBody: ExprNode
}

protocol ExprNode: Node {
    var type: ClassType { get }
}

struct NoExprNode: ExprNode {
    static let instance: NoExprNode = .init()
    let location = SourceLocation(fileName: "", lineNumber: 0)
    var type: ClassType = .none
}

struct BoolExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let value: Bool
}

struct StringExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let value: StringSymbol
}

struct IntExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let value: IntSymbol
}

struct NegateExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
}

struct IsvoidExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
}

struct DispatchExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
    let staticClass: ClassType
    let methodName: IdSymbol
    let args: [ExprNode]

    var isStaticDispatch: Bool {
        if case .none = staticClass {
            return false
        } else {
            return true
        }
    }
}

enum ArithOp { case plus, sub, mul, div }

struct ArithExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr1: ExprNode
    let op: ArithOp
    let expr2: ExprNode
}

enum CompOp { case eq, lt, le }

struct CompareExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr1: ExprNode
    let op: CompOp
    let expr2: ExprNode
}

struct NotExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
}

struct AssignExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: IdSymbol
    let expr: ExprNode
}

struct ObjectExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: IdSymbol
}

struct NewExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let newType: ClassType
}

struct ConditionalExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let predExpr: ExprNode
    let thenExpr: ExprNode
    let elseExpr: ExprNode
}

struct LoopExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let predExpr: ExprNode
    let body: ExprNode
}

struct Branch: SourceLocated {  // TODO: should branch be a node?
    let location: SourceLocation
    let bindName: IdSymbol
    let bindType: ClassType
    let body: ExprNode
}

struct CaseExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
    let branches: [Branch]
}

struct BlockExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let exprs: [ExprNode]
}

struct LetExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: IdSymbol
    let varType: ClassType
    let initExpr: ExprNode
    let bodyExpr: ExprNode
}
