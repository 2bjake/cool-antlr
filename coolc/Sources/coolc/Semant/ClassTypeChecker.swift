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
                guard hasConformance(paramTypes[i], to: formalTypes[i]) else {
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
