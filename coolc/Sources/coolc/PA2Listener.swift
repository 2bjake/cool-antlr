//
//  PA2Listener.swift
//
//
//  Created by Jake Foster on 8/7/20.
//

import Antlr4
import Foundation

extension ParserRuleContext {
    var lineNum: Int { getStart()!.getLine() }
    var text: String { getStart()!.getText()! }
}

class PA2Listener: CoolBaseListener {
    var errorCount = 0

    override func enterProgram(_ ctx: CoolParser.ProgramContext) {
        if ctx.getChildCount() == 0 {
            errorCount += 1
            let msg = makeErrorMsg(at: "EOF")
            printError(msg, 0)
        }
    }

    override func enterCompare(_ ctx: CoolParser.CompareContext) {
        if let expr = ctx.expr().first(where: { $0 is CoolParser.CompareContext}) {
            errorCount += 1
            let msg = makeErrorMsg(at: expr.text)
            printError(msg, expr.lineNum)
        }
    }
}