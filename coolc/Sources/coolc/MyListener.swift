//
//  MyListener.swift
//
//
//  Created by Jake Foster on 8/5/20.
//
import Antlr4
import Foundation

extension CoolParser.ClassDeclContext {
    var className: String { TYPEID(0)!.description }
    var superClassName: String? { TYPEID(1)?.description }
}

class MyListener: CoolBaseListener {

    override func enterClassDecl(_ ctx: CoolParser.ClassDeclContext) {
        print("\(ctx.className) inherits from \(ctx.superClassName ?? "Object") and has \(ctx.feature().count ?? 0) features")
    }

    override func enterAttr(_ ctx: CoolParser.AttrContext) {
        print("attr named \(ctx.OBJECTID()!) of type \(ctx.TYPEID()!)")
    }

    override func enterMethod(_ ctx: CoolParser.MethodContext) {
        print("method named \(ctx.OBJECTID()!)() which returns type \(ctx.TYPEID()!)")
    }
}
