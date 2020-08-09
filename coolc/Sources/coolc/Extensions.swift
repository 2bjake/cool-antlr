//
//  Extensions.swift
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
