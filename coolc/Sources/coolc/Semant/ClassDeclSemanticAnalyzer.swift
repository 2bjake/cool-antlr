//
//  ClassDeclSemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

struct SemanticError: Error {
    let message: String
    let lineNumber: Int
}

struct ClassDeclSemanticAnalyzer {
    private var errCount = 0
    private(set) var validClasses = [ClassType: ClassNode]()

    private mutating func printError(message: String, location: SourceLocation) {
        errCount += 1
        errPrint("\(location.fileName):\(location.lineNumber): \(message)")
    }

    private mutating func checkClassRules(_ classNode: ClassNode) -> Bool {
        guard classNode.classType != .selfType else {
            let msg = "SELF_TYPE cannot be used as a class name"
            printError(message: msg, location: classNode.location)
            return false
        }

        guard !classNode.classType.isBuiltInClass else {
            printError(message: "Class \(classNode.classType) is a built-in class and cannot be redefined", location: classNode.location)
            return false
        }

        guard classNode.parentType != .selfType && classNode.parentType != classNode.classType else {
            printError(message: "Class \(classNode.classType) cannot inherit from itself", location: classNode.location)
            return false
        }

        for constantType in ClassType.constantTypes {
            guard classNode.parentType != constantType else {
                printError(message: "Class \(classNode.classType) cannot inherit from \(constantType)", location: classNode.location)
                return false
            }
        }

        guard validClasses[classNode.classType] == nil else {
            printError(message: "Class \(classNode.classType) already defined", location: classNode.location)
            return false
        }

        return true
    }

    private mutating func installBasicClasses(ast: inout ProgramNode) {
        let location = SourceLocation(fileName: "<basic class>", lineNumber: 0)

        func makeMethod(name: String, type: ClassType, formals: [Formal] = []) -> Feature {
            .method(MethodNode(location: location, type: type, name: name, formals: formals, body: NoExprNode()))
        }

        func makeFormal(name: String, type: ClassType) -> Formal {
            Formal(location: location, type: type, name: name)
        }

        func makePrimitiveSlot() -> Feature {
            .attribute(AttributeNode(location: location, type: .none, name: Symbols.val, initBody: NoExprNode()))
        }

        var builtInClasses = [ClassNode]()

        builtInClasses.append(ClassNode(location: location, classType: .object, parentType: .none, features: [
            makeMethod(name: Symbols.abort, type: .object),
            makeMethod(name: Symbols.typeName, type: .string),
            makeMethod(name: Symbols.copy, type: .selfType)
        ]))

        builtInClasses.append(ClassNode(location: location, classType: .io, parentType: .object, features: [
            makeMethod(name: Symbols.outString, type: .selfType, formals: [makeFormal(name: Symbols.arg, type: .string)]),
            makeMethod(name: Symbols.outInt, type: .selfType, formals: [makeFormal(name: Symbols.arg, type: .int)]),
            makeMethod(name: Symbols.inString, type: .string),
            makeMethod(name: Symbols.inInt, type: .int)
        ]))

        builtInClasses.append(ClassNode(location: location, classType: .int, parentType: .object, features: [makePrimitiveSlot()]))

        builtInClasses.append(ClassNode(location: location, classType: .bool, parentType: .object, features: [makePrimitiveSlot()]))

        builtInClasses.append(ClassNode(location: location, classType: .string, parentType: .object, features: [
            .attribute(AttributeNode(location: location, type: .int, name: Symbols.val, initBody: NoExprNode())),
            makePrimitiveSlot(),
            makeMethod(name: Symbols.length, type: .int),
            makeMethod(name: Symbols.concat, type: .string, formals: [makeFormal(name: Symbols.arg, type: .string)]),
            makeMethod(name: Symbols.substr, type: .string)

        ]))

        ast.addClasses(builtInClasses)
        builtInClasses.forEach { validClasses[$0.classType] = $0 }
    }

    private mutating func checkClassInheritance(_ classNode: ClassNode) {
        let classType = classNode.classType
        let parentType = classNode.parentType

        if parentType != .none && validClasses[parentType] == nil {
            printError(message: "Class \(classType) cannot inherit from \(parentType) because \(parentType) is not defined", location: classNode.location)
        }

        var hasCycle = false
        var curNode = validClasses[parentType]
        while let node = curNode, !hasCycle {
            if node.classType == classType {
                printError(message: "Class \(classType) has an inheritance cycle", location: classNode.location)
                hasCycle = true
            }
            curNode = validClasses[node.parentType]
        }
    }

    // Installs basic classes into the AST and verifies that all
    // class declarations are valid (including a check for inheritance cycles)
    mutating func analyze(ast: inout ProgramNode) throws {
        for node in ast.classes {
            if checkClassRules(node) {
                validClasses[node.classType] = node
            }
        }

        if !validClasses.keys.contains(.main) {
            printError(message: "Class Main is not defined.", location: ast.location)
        }

        if errCount > 0 {
            throw CompilerError.semanticError
        }

        installBasicClasses(ast: &ast)

        // check inheritance
        validClasses.values.forEach { checkClassInheritance($0) }

        if errCount > 0 {
            throw CompilerError.semanticError
        }
    }
}
