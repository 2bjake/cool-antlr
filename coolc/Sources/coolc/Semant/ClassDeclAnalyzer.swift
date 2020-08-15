//
//  ClassDeclAnalyzer.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

struct SemanticError: Error {
    let message: String
    let lineNumber: Int
}

struct ClassDeclAnalyzer {
    private var errCount = 0
    private var validClasses = [ClassType: ClassNode]()

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

        guard classNode.parentType.isInheritable else {
            printError(message: "Class \(classNode.classType) cannot inherit from \(classNode.parentType)", location: classNode.location)
            return false
        }

        guard validClasses[classNode.classType] == nil else {
            printError(message: "Class \(classNode.classType) already defined", location: classNode.location)
            return false
        }

        return true
    }

    private mutating func installBasicClasses(ast: inout ProgramNode) -> ClassNode {
        let location = SourceLocation(fileName: "<basic class>", lineNumber: 0)

        func makeMethod(name: IdSymbol, type: ClassType, formals: [Formal] = []) -> Feature {
            .method(MethodNode(location: location, type: type, name: name, formals: formals, body: NoExprNode()))
        }

        func makeFormal(name: IdSymbol, type: ClassType) -> Formal {
            Formal(location: location, type: type, name: name)
        }

        func makePrimitiveSlot() -> Feature {
            .attribute(AttributeNode(location: location, type: .none, name: .val, initBody: NoExprNode()))
        }

        var builtInClasses = [ClassNode]()

        let objectClass = ClassNode(location: location, classType: .object, parentType: .none, features: [
            makeMethod(name: .abort, type: .object),
            makeMethod(name: .typeName, type: .string),
            makeMethod(name: .copy, type: .selfType)
        ])
        builtInClasses.append(objectClass)

        builtInClasses.append(ClassNode(location: location, classType: .io, parentType: .object, features: [
            makeMethod(name: .outString, type: .selfType, formals: [makeFormal(name: .arg, type: .string)]),
            makeMethod(name: .outInt, type: .selfType, formals: [makeFormal(name: .arg, type: .int)]),
            makeMethod(name: .inString, type: .string),
            makeMethod(name: .inInt, type: .int)
        ]))

        builtInClasses.append(ClassNode(location: location, classType: .int, parentType: .object, features: [makePrimitiveSlot()]))

        builtInClasses.append(ClassNode(location: location, classType: .bool, parentType: .object, features: [makePrimitiveSlot()]))

        builtInClasses.append(ClassNode(location: location, classType: .string, parentType: .object, features: [
            .attribute(AttributeNode(location: location, type: .int, name: .val, initBody: NoExprNode())),
            makePrimitiveSlot(),
            makeMethod(name: .length, type: .int),
            makeMethod(name: .concat, type: .string, formals: [makeFormal(name: .arg, type: .string)]),
            makeMethod(name: .substr, type: .string)

        ]))

        ast.addClasses(builtInClasses)
        builtInClasses.forEach { validClasses[$0.classType] = $0 }
        return objectClass
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

        if !hasCycle, let parent = validClasses[classNode.parentType] {
            parent.addChildClass(classNode)
        }
    }

    // Installs basic classes into the AST and verifies that all
    // class declarations are valid (including a check for inheritance cycles)
    // returns the root node of the class hierarchy (Object)
    mutating func analyze(ast: inout ProgramNode) throws -> (allTypes: [ClassType], objectClass: ClassNode) {
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

        let objectClass = installBasicClasses(ast: &ast)

        // check inheritance
        validClasses.values.forEach { checkClassInheritance($0) }

        if errCount > 0 {
            throw CompilerError.semanticError
        } else {
            return (Array(validClasses.keys), objectClass)
        }
    }
}
