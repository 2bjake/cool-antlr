//
//  TypeChecker.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

protocol ClassTypeChecker {
    func check(classNode: ClassNode) -> [String]
}

func makeTypeChecker(objectTypeTable: SymbolTable<ClassType>, classes: [ClassType: ClassNode]) -> ClassTypeChecker {
    ClassTypeCheckerVisitor(objectTypeTable: objectTypeTable, classes: classes)
}

private class ClassTypeCheckerVisitor: BaseVisitor, ClassTypeChecker {
    private var currentType: ClassType = .none
    private var objectTypeTable: SymbolTable<ClassType>
    private let classes: [ClassType: ClassNode]
    private var errors = [String]()

    private func saveError(_ message: String, _ located: SourceLocated) {
        errors.append("\(located.location.fileName):\(located.location.lineNumber): \(message)")
    }

    init(objectTypeTable: SymbolTable<ClassType>, classes: [ClassType: ClassNode]) {
        self.objectTypeTable = objectTypeTable
        self.classes = classes
    }

    func check(classNode: ClassNode) -> [String] {
        currentType = classNode.classType
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

    private func getMatchingMethod(named name: IdSymbol, withParamTypes paramTypes: [ClassType], on classNode: ClassNode) -> MethodNode? {
        if let method = classNode.methods[name] {
            let formalTypes = method.formals.map(\.type)
            guard formalTypes == paramTypes else { return nil }
            return method
        } else if let parentNode = classes[classNode.parentType] {
            return getMatchingMethod(named: name, withParamTypes: paramTypes, on: parentNode)
        } else {
            return nil
        }
    }

    private func trueType(of type: ClassType) -> ClassType {
        type == .selfType ? currentType : type
    }

    override func visit(_ node: DispatchExprNode) {
        visit(node.expr)
        guard node.expr.type != .none else { return }
        guard let dispatchClass = classes[trueType(of: node.expr.type)] else { return }

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
        node.type = method.type == .selfType ? currentType : method.type
    }

    override func visit(_ node: ObjectExprNode) {
        guard let varType = objectTypeTable.lookup(node.varName) else {
            saveError("\(node.varName) is undefined", node)
            return
        }
        node.type = varType
    }
}
