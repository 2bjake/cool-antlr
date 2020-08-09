//
//  SemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/8/20.
//

import Antlr4
import Foundation

enum Symbols {
    static let selfType = "SELF_TYPE"
    static let selfName = "self"

    static let objectTypeName = "Object"
    static let boolTypeName = "Bool"
    static let stringTypeName = "String"
    static let intTypeName = "Int"
    static let ioTypeName = "IO"
    static let mainTypeName = "Main"

    static let mainMethod = "main"

    static let arg = "arg"
    static let arg2 = "arg2"
    static let concat = "concat"
    static let abort = "abort"
    static let copy = "copy"
    static let inInt = "in_int"
    static let inString = "in_string"
    static let length = "length"
    static let noClass = "_no_class"
    static let noType = "_no_type"
    static let outInt = "out_int"
    static let outString = "out_string"
    static let primSlot = "_prim_slot"
    static let strField = "_str_field"
    static let substr = "substr"
    static let typeName = "type_name"
    static let val = "_val"
}


// processes tree to detect semantic errors
class SemanticAnalyzer: CoolBaseListener {
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
        guard ctx.className != Symbols.selfType else {
            let msg = "SELF_TYPE cannot be used as a class name"
            reportError(msg, ctx.lineNum)
            return
        }

        guard !isBuiltInClass(ctx.className) else {
            reportError("Class \(ctx.className) is a built-in class and cannot be redefined", ctx.lineNum)
            return
        }

        guard ctx.parentName != Symbols.selfType && ctx.parentName != ctx.className else {
            reportError("Class \(ctx.className) cannot inherit from itself", ctx.lineNum)
            return
        }

        for basicClass in [Symbols.boolTypeName, Symbols.intTypeName, Symbols.stringTypeName] {
            guard ctx.parentName != basicClass else {
                reportError("Class \(ctx.className) cannot inherit from \(basicClass)", ctx.lineNum)
                return
            }
        }

        guard classes[ctx.className] == nil else {
            reportError("Class \(ctx.className) already defined", ctx.lineNum)
            return
        }

        classes[ctx.className] = ctx
    }

    override func enterAssign(_ ctx: CoolParser.AssignContext) {
        if ctx.ObjectId()?.getText() == Symbols.selfName {
            reportError("Cannot assign to self", ctx.lineNum)
        }
    }

    override func enterFormals(_ ctx: CoolParser.FormalsContext) {
        var formalSet = Set<String>()
        for f in ctx.formal() {
            let name = f.ObjectId()!.getText()
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
            let parentName = classCtx.parentName

            if !isBuiltInClass(parentName) && classes[parentName] == nil {
                reportError("Class \(className) cannot inherit from \(parentName) because \(parentName) is not defined", classCtx.lineNum)
            }

            var hasCycle = false
            var curCtx = classes[parentName]
            while let ctx = curCtx, !hasCycle {
                if ctx.className == className {
                    reportError("Class \(className) has an inheritance cycle", classCtx.lineNum)
                    hasCycle = true
                }
                curCtx = classes[ctx.parentName]
            }

            /*

             // if inheritance checks out, add c to parent's children
             Class_ parent = class_for_symbol(c->get_parent_sym());
             if (!has_cycle && parent != NULL) {
                 parent->add_child(c->get_name());
             }
             */

        }
    }
}

