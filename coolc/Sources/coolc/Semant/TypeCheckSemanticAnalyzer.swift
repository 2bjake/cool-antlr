//
//  TypeCheckSemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

struct TypeCheckSemanticAnalyzer {
    private let program: ProgramNode
    private let objectClass: ClassNode
    private let definedTypes: [ClassType]
    private var objectTypeTable = SymbolTable<ClassType>()
    private var methodTable = SymbolTable<MethodNode>()
    private var errorCount = 0

    private mutating func printError(_ message: String, _ located: SourceLocated) {
        errorCount += 1
        errPrint("\(located.location.fileName):\(located.location.lineNumber): \(message)")
    }

    init(program: ProgramNode, objectClass: ClassNode) {
        self.program = program
        self.objectClass = objectClass
        definedTypes = program.classes.map(\.classType)
    }

    private func isDefinedType(_ type: ClassType, allowSelfType: Bool = true) -> Bool {
        definedTypes.contains(type) || (allowSelfType && type == .selfType)
    }

    mutating func checkAttribute(_ attribute: AttributeNode) {
        guard isDefinedType(attribute.type) else {
            let msg = "Attribute \(attribute.name) type \(attribute.type) is undefined"
            printError(msg, attribute)
            return
        }

        guard attribute.name != .selfName else {
            printError("self cannot be used as an attribute name", attribute)
            return
        }

        guard !objectTypeTable.contains(attribute.name) else {
            printError("\(attribute.name) cannot be redefined", attribute)
            return
        }

        objectTypeTable.insert(id: attribute.name, data: attribute.type)
    }

    mutating func checkMethod(_ method: MethodNode) {
        guard isDefinedType(method.type) else {
            printError("Method \(method.name) return type \(method.type) is undefined", method)
            return
        }

        guard method.name != .selfName else {
            printError("self cannot be used as a method name", method)
            return
        }

        checkFormals(method: method)
        checkOverride(method: method)
        methodTable.insert(id: method.name, data: method)
    }

    mutating func checkFormals(method: MethodNode) {
        var formalNames = Set<IdSymbol>()
        for formal in method.formals {
            guard isDefinedType(formal.type, allowSelfType: false) else {
                let msg = "Method \(method.name) parameter \(formal.name) has undefined type \(formal.type)"
                printError(msg, formal)
                return
            }

            guard formal.name != .selfName else {
                printError("Cannot use self as parameter name in method \(method.name)", formal)
                return
            }

            guard !formalNames.contains(formal.name) else {
                let msg = "Cannot use the same paramater name \(formal.name) more than once in method \(method.name)"
                printError(msg, formal)
                return
            }
            formalNames.insert(formal.name)
        }
    }

    mutating func checkOverride(method: MethodNode) {
        guard let superMethod = methodTable.lookup(method.name) else { return } // not an override

        guard method.type == superMethod.type else {
            let msg = "In redefined method \(method.name), return type \(method.type) is different from original type \(superMethod.type)"
            printError(msg, method)
            return
        }

        guard method.formals.map(\.type) == superMethod.formals.map(\.type) else {
            printError("Incompatible parameters to override method \(method.name)", method)
            return
        }
    }

    mutating func checkClass(_ classNode: ClassNode) {
        objectTypeTable.enterScope()
        methodTable.enterScope()
        classNode.attributes.forEach { checkAttribute($0) }
        classNode.methods.forEach { checkMethod($0) }

        // check if Main class has a main method
        if classNode.classType == .main && methodTable.probe(.mainMethod) == nil {
            printError("class Main must have a main method", classNode)
        }

        if !classNode.classType.isBuiltInClass {
            objectTypeTable.enterScope()
            objectTypeTable.insert(id: .selfName, data: .selfType)
            // TODO: classNode.features.typeCheck()
            objectTypeTable.exitScope()
        }

        classNode.childClasses.filter(\.classType.isInheritable).forEach { checkClass($0) }
        objectTypeTable.exitScope()
        methodTable.exitScope()
    }

    mutating func analyze() throws {
        checkClass(objectClass)
        if errorCount > 0 {
            throw CompilerError.semanticError
        }
    }
}
