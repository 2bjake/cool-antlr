//
//  ClassAnalyzer.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

import Antlr4
import Foundation

struct SemanticError: Error {
    let message: String
    let lineNumber: Int
}

// first pass semantic evaluator for classes
struct ClassAnalyzer {
    private static let builtInClassNames = [Symbols.objectTypeName, Symbols.intTypeName, Symbols.boolTypeName, Symbols.stringTypeName, Symbols.ioTypeName]

    private static func isBuiltInClass(_ name: String) -> Bool { builtInClassNames.contains(name) }

    // TODO: allow preloading of "other classes" to support multiple source files

    private(set) var checkedClasses: [String: CoolParser.ClassDeclContext] = [:]

    mutating func checkClass(_ ctx: CoolParser.ClassDeclContext) throws {

        guard ctx.classTypeName != Symbols.selfType else {
            let msg = "SELF_TYPE cannot be used as a class name"
            throw SemanticError(message: msg, lineNumber: ctx.lineNum)
        }

        guard !Self.isBuiltInClass(ctx.classTypeName) else {
            throw SemanticError(message: "Class \(ctx.classTypeName) is a built-in class and cannot be redefined", lineNumber: ctx.lineNum)
        }

        guard ctx.parentTypeName != Symbols.selfType && ctx.parentTypeName != ctx.classTypeName else {
            throw SemanticError(message: "Class \(ctx.classTypeName) cannot inherit from itself", lineNumber: ctx.lineNum)
        }

        for basicClass in [Symbols.boolTypeName, Symbols.intTypeName, Symbols.stringTypeName] {
            guard ctx.parentTypeName != basicClass else {
                throw SemanticError(message: "Class \(ctx.classTypeName) cannot inherit from \(basicClass)", lineNumber: ctx.lineNum)
            }
        }

        guard checkedClasses[ctx.classTypeName] == nil else {
            throw SemanticError(message: "Class \(ctx.classTypeName) already defined", lineNumber: ctx.lineNum)
        }

        checkedClasses[ctx.classTypeName] = ctx
    }

    func checkClasses() throws {
        if !checkedClasses.keys.contains(Symbols.mainTypeName) {
            throw SemanticError(message: "Class Main is not defined.", lineNumber: 0)
        }

        for className in checkedClasses.keys {
            let classCtx = checkedClasses[className]!
            let parentName = classCtx.parentTypeName

            if !Self.isBuiltInClass(parentName) && checkedClasses[parentName] == nil {
                throw SemanticError(message: "Class \(className) cannot inherit from \(parentName) because \(parentName) is not defined", lineNumber: classCtx.lineNum)
            }

            var curCtx = checkedClasses[parentName]
            while let ctx = curCtx {
                if ctx.classTypeName == className {
                    throw SemanticError(message: "Class \(className) has an inheritance cycle", lineNumber: classCtx.lineNum)
                }
                curCtx = checkedClasses[ctx.parentTypeName]
            }
        }
    }
}
