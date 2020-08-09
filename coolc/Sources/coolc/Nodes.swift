//
//  Nodes.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Foundation

enum ClassType {
    case none
    case selfType
    case object
    case io
    case bool
    case int
    case string
    case defined(String)

    init(_ str: String) {
        switch str {
            case Symbols.selfType: self = .selfType
            case Symbols.objectTypeName: self = .object
            case Symbols.ioTypeName: self = .io
            case Symbols.boolTypeName: self = .bool
            case Symbols.intTypeName: self = .int
            case Symbols.stringTypeName: self = .string
            default: self = .defined(str)
        }
    }
}

struct SourceLocation {
    let fileName: String
    let lineNumber: Int
}

protocol SourceLocated {
    var location: SourceLocation { get }
}

protocol Node: SourceLocated {}

struct ProgramNode: Node {
    let location: SourceLocation
    let classes: [ClassNode]
}

struct ClassNode: Node {
    let location: SourceLocation
    let classType: ClassType
    let parentType: ClassType
    let methods: [MethodNode]
    let attributes: [AttributeNode]
}

struct Formal {
    let location: SourceLocation
    let type: ClassType
    let name: String
}

struct MethodNode: Node {
    let location: SourceLocation
    let type: ClassType
    let name: String
    let formals: [Formal]
    let body: ExprNode
}

struct AttributeNode: Node {
    let location: SourceLocation
    let type: ClassType
    let name: String
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

struct ConstantExpr<T>: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let value: T
}

struct NegateExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
}

struct IsvoidExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
}

struct DispatchExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
    let staticClass: ClassType?
    let methodName: String
    let args: [ExprNode]
}

struct ArithExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr1: ExprNode
    let op: ArithOp
    let expr2: ExprNode
}

struct CompareExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr1: ExprNode
    let op: CompOp
    let expr2: ExprNode
}

struct NotExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
}

struct AssignExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: String
    let expr: ExprNode
}

struct ObjectExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: String
}

struct NewExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let newType: ClassType
}

struct ConditionalExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let predExpr: ExprNode
    let thenExpr: ExprNode
    let elseExpr: ExprNode
}

struct LoopExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let predExpr: ExprNode
    let body: ExprNode
}

struct Branch {
    let location: SourceLocation
    let bindName: String
    let bindType: ClassType
    let body: ExprNode
}

struct CaseExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
    let branches: [Branch]
}

struct BlockExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let exprs: [ExprNode]
}

struct LetExpr: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: String
    let varType: ClassType
    let initExpr: ExprNode
    let bodyExpr: ExprNode
}
