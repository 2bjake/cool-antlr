//
//  AntlrSemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/8/20.
//

import Antlr4
import Foundation

// processes tree to detect semantic errors
class AntlrSemanticAnalyzer: CoolBaseListener {
    private let builtInClassNames = [Symbols.objectTypeName, Symbols.intTypeName, Symbols.boolTypeName, Symbols.stringTypeName, Symbols.ioTypeName]
    private let fileName: String
    var errorCount = 0
    private var classes: [String: CoolParser.ClassDeclContext] = [:]

    private func isBuiltInClass(_ name: String) -> Bool { builtInClassNames.contains(name) }

    init(fileName: String) {
        self.fileName = fileName
    }

    func reportError(_ msg: String, _ line: Int) {
        errorCount += 1
        errPrint("\(fileName):\(line): \(msg)")
    }

    override func enterClassDecl(_ ctx: CoolParser.ClassDeclContext) {
        guard ctx.classTypeName != Symbols.selfType else {
            let msg = "SELF_TYPE cannot be used as a class name"
            reportError(msg, ctx.lineNum)
            return
        }

        guard !isBuiltInClass(ctx.classTypeName) else {
            reportError("Class \(ctx.classTypeName) is a built-in class and cannot be redefined", ctx.lineNum)
            return
        }

        guard ctx.parentTypeName != Symbols.selfType && ctx.parentTypeName != ctx.classTypeName else {
            reportError("Class \(ctx.classTypeName) cannot inherit from itself", ctx.lineNum)
            return
        }

        for basicClass in [Symbols.boolTypeName, Symbols.intTypeName, Symbols.stringTypeName] {
            guard ctx.parentTypeName != basicClass else {
                reportError("Class \(ctx.classTypeName) cannot inherit from \(basicClass)", ctx.lineNum)
                return
            }
        }

        guard classes[ctx.classTypeName] == nil else {
            reportError("Class \(ctx.classTypeName) already defined", ctx.lineNum)
            return
        }

        classes[ctx.classTypeName] = ctx
    }

    override func enterAssign(_ ctx: CoolParser.AssignContext) {
        if ctx.ObjectId()?.getText() == Symbols.selfName {
            reportError("Cannot assign to self", ctx.lineNum)
        }
    }

    override func enterFormals(_ ctx: CoolParser.FormalsContext) {
        var formalSet = Set<String>()
        for formal in ctx.formal() {
            let name = formal.ObjectId()!.getText()
            if !formalSet.insert(name).inserted {
                reportError("Duplicate name \(name) in formals list", ctx.lineNum)
            }
        }
    }

    override func enterFormal(_ ctx: CoolParser.FormalContext) {
        if ctx.typeName == Symbols.selfType {
            reportError("Cannot use SELF_TYPE as parameter type", ctx.lineNum)
        }
    }

    override func enterAttr(_ ctx: CoolParser.AttrContext) {
        if ctx.text == Symbols.selfName {
            reportError("Cannot use self as attribute name", ctx.lineNum)
        }
    }

    override func exitProgram(_ programCtx: CoolParser.ProgramContext) {
        // TODO: how to represent built-in classes?

        if !classes.keys.contains(Symbols.mainTypeName) {
            reportError("Class Main is not defined.", programCtx.lineNum)
        }

        for className in classes.keys {
            let classCtx = classes[className]!
            let parentName = classCtx.parentTypeName

            if !isBuiltInClass(parentName) && classes[parentName] == nil {
                reportError("Class \(className) cannot inherit from \(parentName) because \(parentName) is not defined", classCtx.lineNum)
            }

            var hasCycle = false
            var curCtx = classes[parentName]
            while let ctx = curCtx, !hasCycle {
                if ctx.classTypeName == className {
                    reportError("Class \(className) has an inheritance cycle", classCtx.lineNum)
                    hasCycle = true
                }
                curCtx = classes[ctx.parentTypeName]
            }
        }
    }
}
