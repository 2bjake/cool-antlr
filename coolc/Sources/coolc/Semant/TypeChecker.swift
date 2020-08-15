//
//  TypeChecker.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

protocol ClassTypeChecker {
    func check(classNode: ClassNode) -> [String]
}

func makeTypeChecker(objectTypeTable: SymbolTable<ClassType>, allTypes: [ClassType]) -> ClassTypeChecker {
    ClassTypeCheckerVisitor(objectTypeTable: objectTypeTable, allTypes: allTypes)
}

private class ClassTypeCheckerVisitor: BaseVisitor, ClassTypeChecker {
    private var currentType: ClassType = .none
    private var objectTypeTable: SymbolTable<ClassType>
    private let allTypes: [ClassType]
    private var errors = [String]()

    private func saveError(_ message: String, _ located: SourceLocated) {
        errors.append("\(located.location.fileName):\(located.location.lineNumber): \(message)")
    }

    init(objectTypeTable: SymbolTable<ClassType>, allTypes: [ClassType]) {
        self.objectTypeTable = objectTypeTable
        self.allTypes = allTypes
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
}
