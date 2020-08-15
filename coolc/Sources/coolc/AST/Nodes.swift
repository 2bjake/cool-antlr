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

protocol Node: SourceLocated, PA2Named, Visitable {}

class ProgramNode: Node {
    let location: SourceLocation
    private(set) var classes: [ClassNode]

    func addClasses(_ classNodes: [ClassNode]) {
        classes.append(contentsOf: classNodes)
    }

    init(location: SourceLocation, classes: [ClassNode]) {
        self.location = location
        self.classes = classes
    }
}

enum Feature {
    case method(MethodNode)
    case attribute(AttributeNode)
}

class ClassNode: Node {
    let location: SourceLocation
    let classType: ClassType
    let parentType: ClassType
    let features: [Feature]

    lazy private(set) var methods: [IdSymbol: MethodNode] = {
        let methodList: [MethodNode] = features.compactMap {
            if case .method(let method) = $0 { return method }
            return nil
        }

        return methodList.reduce(into: [:]) { result, methodNode in
            result[methodNode.name] = methodNode
        }
    }()

    lazy private(set) var attributes: [AttributeNode] = {
        features.compactMap {
            if case .attribute(let attribute) = $0 { return attribute }
            return nil
        }
    }()

    private(set) var childClasses: [ClassNode] = []

    init(location: SourceLocation, classType: ClassType, parentType: ClassType, features: [Feature]) {
        self.location = location
        self.classType = classType
        self.parentType = parentType
        self.features = features
    }

    func addChildClass(_ childClass: ClassNode) {
        childClasses.append(childClass)
    }
}

struct Formal: SourceLocated {
    let location: SourceLocation
    let type: ClassType
    let name: IdSymbol
}

class MethodNode: Node {
    let location: SourceLocation
    let type: ClassType
    let name: IdSymbol
    let formals: [Formal]
    let body: ExprNode

    init(location: SourceLocation, type: ClassType, name: IdSymbol, formals: [Formal], body: ExprNode) {
        self.location = location
        self.type = type
        self.name = name
        self.formals = formals
        self.body = body
    }
}

class AttributeNode: Node {
    let location: SourceLocation
    let type: ClassType
    let name: IdSymbol
    let initBody: ExprNode

    var hasInit: Bool { !(initBody is NoExprNode) }

    init(location: SourceLocation, type: ClassType, name: IdSymbol, initBody: ExprNode) {
        self.location = location
        self.type = type
        self.name = name
        self.initBody = initBody
    }
}

protocol ExprNode: Node {
    var type: ClassType { get }
}

struct NoExprNode: ExprNode {
    static let instance: NoExprNode = .init()
    let location = SourceLocation(fileName: "", lineNumber: 0)
    let type: ClassType = .none
}

struct BoolExprNode: ExprNode {
    let location: SourceLocation
    let type: ClassType = .bool
    let value: Bool
}

struct StringExprNode: ExprNode {
    let location: SourceLocation
    let type: ClassType = .string
    let value: StringSymbol
}

struct IntExprNode: ExprNode {
    let location: SourceLocation
    let type: ClassType = .int
    let value: IntSymbol
}

class NegateExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode

    init(location: SourceLocation, expr: ExprNode) {
        self.location = location
        self.expr = expr
    }
}

class IsvoidExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode

    init(location: SourceLocation, expr: ExprNode) {
        self.location = location
        self.expr = expr
    }
}

class DispatchExprNode: ExprNode {
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

    init(location: SourceLocation, expr: ExprNode, staticClass: ClassType, methodName: IdSymbol, args: [ExprNode]) {
        self.location = location
        self.expr = expr
        self.staticClass = staticClass
        self.methodName = methodName
        self.args = args
    }
}

enum ArithOp: String {
    case plus = "+"
    case sub = "-"
    case mul = "*"
    case div = "/"
}

extension ArithOp: CustomStringConvertible {
    var description: String { rawValue }
}

class ArithExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr1: ExprNode
    let op: ArithOp
    let expr2: ExprNode

    init(location: SourceLocation, expr1: ExprNode, op: ArithOp, expr2: ExprNode) {
        self.location = location
        self.expr1 = expr1
        self.op = op
        self.expr2 = expr2
    }
}

enum CompOp: String {
    case eq = "="
    case lt = "<"
    case le = "<="
}

extension CompOp: CustomStringConvertible {
    var description: String { rawValue }
}

class CompareExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr1: ExprNode
    let op: CompOp
    let expr2: ExprNode

    init(location: SourceLocation, expr1: ExprNode, op: CompOp, expr2: ExprNode) {
        self.location = location
        self.expr1 = expr1
        self.op = op
        self.expr2 = expr2
    }
}

class NotExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode

    init(location: SourceLocation, expr: ExprNode) {
        self.location = location
        self.expr = expr
    }
}

class AssignExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: IdSymbol
    let expr: ExprNode

    init(location: SourceLocation, varName: IdSymbol, expr: ExprNode) {
        self.location = location
        self.varName = varName
        self.expr = expr
    }
}

class ObjectExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: IdSymbol

    init(location: SourceLocation, varName: IdSymbol) {
        self.location = location
        self.varName = varName
    }
}

class NewExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let newType: ClassType

    init(location: SourceLocation, newType: ClassType) {
        self.location = location
        self.newType = newType
    }
}

class ConditionalExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let predExpr: ExprNode
    let thenExpr: ExprNode
    let elseExpr: ExprNode

    init(location: SourceLocation, predExpr: ExprNode, thenExpr: ExprNode, elseExpr: ExprNode) {
        self.location = location
        self.predExpr = predExpr
        self.thenExpr = thenExpr
        self.elseExpr = elseExpr
    }
}

class LoopExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let predExpr: ExprNode
    let body: ExprNode

    init(location: SourceLocation, predExpr: ExprNode, body: ExprNode) {
        self.location = location
        self.predExpr = predExpr
        self.body = body
    }
}

struct Branch: SourceLocated {  // TODO: should branch be a node?
    let location: SourceLocation
    let bindName: IdSymbol
    let bindType: ClassType
    let body: ExprNode
}

class CaseExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let expr: ExprNode
    let branches: [Branch]

    init(location: SourceLocation, expr: ExprNode, branches: [Branch]) {
        self.location = location
        self.expr = expr
        self.branches = branches
    }
}

class BlockExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let exprs: [ExprNode]

    init(location: SourceLocation, exprs: [ExprNode]) {
        self.location = location
        self.exprs = exprs
    }
}

class LetExprNode: ExprNode {
    let location: SourceLocation
    var type: ClassType = .none
    let varName: IdSymbol
    let varType: ClassType
    let initExpr: ExprNode
    let bodyExpr: ExprNode
    var hasInit: Bool { !(initExpr is NoExprNode) }

    init(location: SourceLocation, varName: IdSymbol, varType: ClassType, initExpr: ExprNode, bodyExpr: ExprNode) {
        self.location = location
        self.varName = varName
        self.varType = varType
        self.initExpr = initExpr
        self.bodyExpr = bodyExpr
    }
}
