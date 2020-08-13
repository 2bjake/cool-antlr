//
//  TypeCheckSemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

extension Sequence {
    func exclude(where pred: (Self.Element) -> Bool) -> [Self.Element] {
        filter { !pred($0) }
    }
}

struct TypeCheckSemanticAnalyzer {
    private let program: ProgramNode
    private let objectClass: ClassNode
    private var objectTypeTable = SymbolTable<ClassType>()
    private var methodTable = SymbolTable<MethodNode>()
    private var errorCount = 0

    private mutating func printError(message: String, location: SourceLocation) {
        errorCount += 1
        errPrint("\(location.fileName):\(location.lineNumber): \(message)")
    }


    init(program: ProgramNode, objectClass: ClassNode) {
        self.program = program
        self.objectClass = objectClass
    }

    mutating func checkAttribute(_ attribute: AttributeNode) {
        // TODO
    }

    mutating func checkMethod(_ method: MethodNode) {
        // TODO
    }

    mutating func checkClass(_ classNode: ClassNode) {
        objectTypeTable.enterScope()
        methodTable.enterScope()
        classNode.attributes.forEach { checkAttribute($0) }
        classNode.methods.forEach { checkMethod($0) }

        // check if Main class has a main method
        if classNode.classType == .main && methodTable.probe(.mainMethod) == nil {
            printError(message: "class Main must have a main method", location: classNode.location)
        }

        if !classNode.classType.isBuiltInClass {
            objectTypeTable.enterScope()
            objectTypeTable.insert(id: .selfName, data: .selfType)
            // TODO: classNode.features.typeCheck()
            objectTypeTable.exitScope()
        }

        classNode.childClasses.forEach { checkClass($0) }

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
