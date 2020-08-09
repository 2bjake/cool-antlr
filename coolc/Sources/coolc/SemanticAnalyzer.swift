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
        let className = ctx.TypeId()[0].getText()
        let superName = ctx.TypeId(1)?.getText() ?? Symbols.objectTypeName

        if className == Symbols.selfType {
            let msg = "SELF_TYPE cannot be used as a class name"
            reportError(msg, ctx.lineNum)
        }

        if isBuiltInClass(className) {
            reportError("Class \(className) is a built-in class and cannot be redefined", ctx.lineNum)
        }

        if superName == Symbols.selfType || superName == className {
            let msg = "Class \(className) cannot inherit from itself"
            reportError(msg, ctx.lineNum)
        } else if superName == Symbols.boolTypeName {
            reportError("Cannot inherit from Bool", ctx.lineNum)
        } else if superName == Symbols.stringTypeName {
            reportError("Cannot inherit from String", ctx.lineNum)
        } else if superName == Symbols.intTypeName {
            reportError("Cannot inherit from Int", ctx.lineNum)
        }

        if classes[className] != nil {
            reportError("Class \(className) already defined", ctx.lineNum)
        } else {
            classes[className] = ctx
        }
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
        if ctx.TypeId()?.getText() == Symbols.selfType {
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
            let parentName = classCtx.TypeId(1)?.getText() ?? Symbols.objectTypeName

            if !isBuiltInClass(parentName) && classes[parentName] == nil {
                reportError("Class \(className) cannot inherit from \(parentName) because \(parentName) is not defined", classCtx.lineNum)
            }

            var hasCycle = false
            var curCtx = classes[parentName]
            while let ctx = curCtx, !hasCycle {
                if ctx.TypeId()[0].getText() == className {
                    reportError("Class \(className) has an inheritance cycle", classCtx.lineNum)
                    hasCycle = true
                }
                curCtx = classes[ctx.TypeId(1)?.getText() ?? ""]
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

