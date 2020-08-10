//
//  SemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/10/20.
//

import Foundation

struct SemanticAnalyzer {

    func installBasicClasses(program: inout ProgramNode) {
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

        let objClass = ClassNode(location: location, classType: .object, parentType: .none, features: [
            makeMethod(name: Symbols.abort, type: .object),
            makeMethod(name: Symbols.typeName, type: .string),
            makeMethod(name: Symbols.copy, type: .selfType)
        ])

        let ioClass = ClassNode(location: location, classType: .io, parentType: .object, features: [
            makeMethod(name: Symbols.outString, type: .selfType, formals: [makeFormal(name: Symbols.arg, type: .string)]),
            makeMethod(name: Symbols.outInt, type: .selfType, formals: [makeFormal(name: Symbols.arg, type: .int)]),
            makeMethod(name: Symbols.inString, type: .string),
            makeMethod(name: Symbols.inInt, type: .int)
        ])

        let intClass = ClassNode(location: location, classType: .int, parentType: .object, features: [makePrimitiveSlot()])

        let boolClass = ClassNode(location: location, classType: .bool, parentType: .object, features: [makePrimitiveSlot()])

        let stringClass = ClassNode(location: location, classType: .string, parentType: .object, features: [
            .attribute(AttributeNode(location: location, type: .int, name: Symbols.val, initBody: NoExprNode())),
            makePrimitiveSlot(),
            makeMethod(name: Symbols.length, type: .int),
            makeMethod(name: Symbols.concat, type: .string, formals: [makeFormal(name: Symbols.arg, type: .string)]),
            makeMethod(name: Symbols.substr, type: .string)

        ])

        program.addClasses(objClass, ioClass, intClass, boolClass, stringClass)
    }

}
