//
//  SyntaxAnalyzer.swift
//
//
//  Created by Jake Foster on 8/7/20.
//

import Antlr4
import Foundation

// processes tree to detect syntax errors not caught in parsing/lexing
class SyntaxAnalyzer: CoolBaseListener {
    private(set) var errorCount = 0
    let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    private func printError(_ msg: String, _ line: Int) {
        errorCount += 1
        errPrint("\"\(fileName)\", line \(line): \(msg)")
    }

    // program must have at least one class
    override func enterProgram(_ ctx: CoolParser.ProgramContext) {
        if ctx.getChildCount() == 0 {
            let msg = makeErrorMsg(at: "EOF")
            printError(msg, 0)
        }
    }

    // expressions like 2 < 3 < 4 are not valid
    override func enterCompare(_ ctx: CoolParser.CompareContext) {
        if let expr = ctx.expr().first(where: { $0 is CoolParser.CompareContext}) {
            let msg = makeErrorMsg(at: expr.text)
            printError(msg, expr.lineNum)
        }
    }
}
