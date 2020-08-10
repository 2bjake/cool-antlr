//
//  AntlrExtensions.swift
//
//
//  Created by Jake Foster on 8/8/20.
//

import Antlr4
import Foundation

extension ParserRuleContext {
    var lineNum: Int { getStart()!.getLine() }
    var text: String { getStart()!.getText()! }
}

extension CoolParser.ClassDeclContext {
    var classTypeName: String { TypeId(0)!.getText() }
    var parentTypeName: String { TypeId(1)?.getText() ?? Symbols.objectTypeName }
}

extension CoolParser.FormalContext {
    var typeName: String { TypeId()!.getText() }
}

enum ArithOp {
    case plus, sub, mul, div
}

enum CompOp {
    case eq, lt, le
}

extension CoolParser.ArithContext {
    var op: ArithOp {
        if Plus() != nil {
            return .plus
        } else if Minus() != nil {
            return .sub
        } else if Star() != nil {
            return .mul
        } else {
            return .div
        }
    }
}

extension CoolParser.CompareContext {
    var op: CompOp {
        if Less() != nil {
            return .lt
        } else if LessEqual() != nil {
            return .le
        } else {
            return .eq
        }
    }
}
