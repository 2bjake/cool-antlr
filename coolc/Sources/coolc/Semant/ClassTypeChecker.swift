//
//  ClassTypeChecker.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

class ClassTypeChecker: BaseVisitor {
    private var classNode: ClassNode
    private var classType: ClassType { classNode.classType }
    private var objectTypeTable: SymbolTable<ClassType>
    private let classes: [ClassType: ClassNode]
    private var errors = [String]()

    private func saveError(_ message: String, _ located: SourceLocated) {
        errors.append("\(located.location.fileName):\(located.location.lineNumber): \(message)")
    }

    init(classNode: ClassNode, objectTypeTable: SymbolTable<ClassType>, classes: [ClassType: ClassNode]) {
        self.classNode = classNode
        self.objectTypeTable = objectTypeTable
        self.classes = classes
    }

    func check() -> [String] {
        visit(classNode)
        return errors
    }

    override func visit(_ node: ClassNode) {
        objectTypeTable.enterScope()
        objectTypeTable.insert(id: .selfName, data: .selfType)
        visitChildren(node)
        objectTypeTable.exitScope()
    }

    override func visit(_ node: AttributeNode) {
        if node.hasInit {
            visit(node.initBody)
            guard node.initBody.type != .none else { return }
            guard hasConformance(node.initBody.type, to: node.type) else {
                let msg = "Initialization type \(node.initBody.type) for attribute \(node.name) does not conform to type \(node.type)"
                saveError(msg, node)
                return
            }
        }
    }

    override func visit(_ node: MethodNode) {
        objectTypeTable.enterScope()
        defer { objectTypeTable.exitScope() }

        for formal in node.formals {
            guard formal.name != .selfName else {
                saveError("self cannot be used as a parameter name in function \(node.name)", node)
                return
            }

            guard formal.type != .selfType else {
                saveError("SELF_TYPE cannot be used as a parameter type in function \(node.name)", node)
                return
            }

            objectTypeTable.insert(id: formal.name, data: formal.type)
        }
        visit(node.body)

        if node.body.type == .selfType && node.type == .selfType {
            return
        }

        guard hasConformance(node.body.type, to: node.type) else {
            let msg = "The type \(node.body.type) returned from method \(node.name) does not conform to the specified return type \(node.type)"
            saveError(msg, node)
            return
        }
    }

    override func visit(_ node: LetExprNode) {
        guard node.varName != .selfName else {
            saveError("Cannot assign a value to self", node)
            return
        }

        if node.hasInit {
            visit(node.initExpr)
            guard node.initExpr.type != .none else { return }
            guard hasConformance(trueType(of: node.initExpr.type), to: trueType(of: node.varType)) else {
                saveError("Initialization type \(node.initExpr.type) for let \(node.varType) does not conform to type \(node.varType)", node)
                return
            }
        }

        objectTypeTable.enterScope()
        objectTypeTable.insert(id: node.varName, data: node.varType)
        visit(node.bodyExpr)
        node.type = node.bodyExpr.type
        objectTypeTable.exitScope()
    }

    override func visit(_ node: NewExprNode) {
        guard node.newType == .selfType || classes[node.newType] != nil else {
            saveError("'new' used with undefined class \(node.newType)", node)
            return
        }
        node.type = node.newType
    }

    override func visit(_ node: CaseExprNode) {
        // TODO
        visitChildren(node)
    }

    override func visit(_ node: LoopExprNode) {
        visitChildren(node)
        guard node.predExpr.type != .none && node.body.type != .none else { return }
        guard node.predExpr.type == .bool else {
            saveError("Loop predicate must be of type Bool", node)
            return
        }
        node.type = .object
    }

    override func visit(_ node: AssignExprNode) {
        guard node.varName != .selfName else {
            saveError("Cannot assign a value to self", node)
            return
        }

        guard let varType = objectTypeTable.lookup(node.varName) else {
            saveError("\(node.varName) is undefined", node)
            return
        }

        visit(node.expr)
        guard node.expr.type != .none else { return }

        guard hasConformance(node.expr.type, to: varType) else {
            saveError("Assignment expression type \(node.expr.type) does not conform to type \(varType)", node)
            return
        }
        node.type = node.expr.type
    }

    override func visit(_ node: IsvoidExprNode) {
        visitChildren(node)
        guard node.expr.type != .none else { return }
        node.type = .bool
    }

    override func visit(_ node: NegateExprNode) {
        visitChildren(node)
        guard node.expr.type != .none else { return }
        guard node.expr.type == .int else {
            saveError("Negate argument does not have type Int", node)
            return
        }
        node.type = .int
    }

    private func buildInheritancePath(_ type: ClassType) -> [ClassType] {
        var cur: ClassNode? = classes[type]
        var path = [ClassType]()
        while cur != nil {
            path.append(cur!.classType)
            cur = classes[cur!.parentType]
        }
        return path
    }

    private func leastType(_ a: ClassType, _ b: ClassType) -> ClassType {
        let aPath = buildInheritancePath(a)
        let bPath = buildInheritancePath(b)

        var ai = aPath.count - 1
        var bi = bPath.count - 1
        while ai >= 0 && bi >= 0 {
            if (aPath[ai] != bPath[bi]) {
                break;
            }
            ai -= 1
            bi -= 1
        }
        return aPath[ai + 1];
    }

    override func visit(_ node: ConditionalExprNode) {
        visitChildren(node)
        guard [node.predExpr, node.thenExpr, node.elseExpr].allSatisfy({ $0.type != .none }) else { return }
        guard node.predExpr.type == .bool else {
            saveError("If predicate must be of type bool", node)
            return
        }
        node.type = leastType(node.thenExpr.type, node.elseExpr.type)
    }

    override func visit(_ node: NotExprNode) {
        visitChildren(node)
        guard node.expr.type != .none else { return }
        guard node.expr.type == .bool else {
            saveError("Argument of not is not of type bool", node)
            return
        }
        node.type = .bool
    }

    override func visit(_ node: BlockExprNode) {
        visitChildren(node)
        guard node.exprs.allSatisfy({ $0.type != .none }) else { return }
        node.type = node.exprs[node.exprs.count - 1].type
    }

    override func visit(_ node: ArithExprNode) {
        visitChildren(node)
        guard node.expr1.type != .none && node.expr1.type != .none else { return }
        guard node.expr1.type == .int && node.expr2.type == .int else {
            let msg = "non-int arguments: \(node.expr1.type) \(node.op) \(node.expr2.type)"
            saveError(msg, node)
            return
        }
        node.type = .int
    }

    override func visit(_ node: CompareExprNode) {
        visitChildren(node)
        guard node.expr1.type != .none && node.expr1.type != .none else { return }

        if node.op == .eq && node.expr1.type.isConstant && node.expr2.type.isConstant {
            guard node.expr1.type == node.expr2.type else {
                saveError("Illegal comparison with a basic type", node)
                return
            }
        } else {
            guard node.expr1.type == .int && node.expr2.type == .int else {
                let msg = "non-int arguments: \(node.expr1.type) \(node.op) \(node.expr2.type)"
                saveError(msg, node)
                return
            }
        }
        node.type = .bool
    }

    private func getMatchingMethod(named name: IdSymbol, withParamTypes paramTypes: [ClassType], on classNode: ClassNode) -> MethodNode? {
        if let method = classNode.methods[name] {
            let formalTypes = method.formals.map(\.type)
            guard formalTypes.count == paramTypes.count else { return nil }

            for i in 0..<formalTypes.count {
                guard hasConformance(trueType(of: paramTypes[i]), to: formalTypes[i]) else {
                    return nil
                }
            }
            return method
        } else if let parentNode = classes[classNode.parentType] {
            return getMatchingMethod(named: name, withParamTypes: paramTypes, on: parentNode)
        } else {
            return nil
        }
    }

    private func trueType(of type: ClassType) -> ClassType {
        type == .selfType ? classType : type
    }

    private func hasConformance(_ classNode: ClassNode, to superNode: ClassNode) -> Bool {
        return hasConformance(classNode.classType, to: superNode.classType)
    }

    private func hasConformance(_ classType: ClassType, to superType: ClassType) -> Bool {
        var current: ClassNode? = classes[classType]
        while current != nil {
            if current!.classType == superType { return true }
            current = classes[current!.parentType]
        }
        return false
    }

    private func getDispatchClass(_ node: DispatchExprNode) -> ClassNode? {
        guard let dynamicClassNode = classes[trueType(of: node.expr.type)] else { return nil }
        if !node.isStaticDispatch { return dynamicClassNode }

        guard let staticClassNode = classes[node.staticClass] else {
            saveError("Static type \(node.staticClass) is undefined", node)
            return nil
        }

        guard hasConformance(dynamicClassNode, to: staticClassNode) else {
            saveError("Expression does not conform to specified static dispatch type \(node.staticClass)", node)
            return nil
        }
        return staticClassNode
    }

    override func visit(_ node: DispatchExprNode) {
        visit(node.expr)
        guard node.expr.type != .none else { return }
        guard let dispatchClass = getDispatchClass(node) else { return }

        var argTypes = [ClassType]()
        for arg in node.args {
            visit(arg)
            guard arg.type != .none else { return }
            argTypes.append(arg.type)
        }

        guard let method = getMatchingMethod(named: node.methodName, withParamTypes: argTypes, on: dispatchClass) else {
            let msg = "There is no method named \(node.methodName) on type \(dispatchClass.classType) which take the specified parameters"
            saveError(msg, node)
            return
        }
        node.type = trueType(of: method.type)
    }

    override func visit(_ node: ObjectExprNode) {
        guard let varType = objectTypeTable.lookup(node.varName) else {
            saveError("\(node.varName) is undefined", node)
            return
        }
        node.type = varType
    }
}
