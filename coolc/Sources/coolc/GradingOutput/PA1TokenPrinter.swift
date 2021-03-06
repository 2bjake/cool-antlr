//
//  PA1TokenPrinter.swift
//
//
//  Created by Jake Foster on 8/5/20.
//
import Antlr4
import Foundation

// prints tokens out in form PA1 grading scripts expect
class PA1TokenPrinter: CoolBaseListener {

    private func printToken(_ symbol: String, _ ctx: CoolParser.TokenContext) {
        printToken(symbol, ctx.lineNum, ctx.text)
    }

    private func printToken(_ symbol: String, _ lineNum: Int, _ value: String = "") {
        print("#\(lineNum) \(symbol) \(value)")
    }

    private func printError(_ message: String, _ lineNum: Int) {
        printToken("ERROR", lineNum, "\"\(message)\"")
    }

    // constants

    override func enterInt(_ ctx: CoolParser.IntContext) {
        printToken("INT_CONST", ctx)
    }

    override func enterString(_ ctx: CoolParser.StringContext) {
        printToken("STR_CONST", ctx.lineNum, "\"\(processString(ctx.text))\"")
    }

    override func enterBool(_ ctx: CoolParser.BoolContext) {
        printToken("BOOL_CONST", ctx.lineNum, ctx.text.lowercased())
    }

    // multi-character operators

    override func enterAssignToken(_ ctx: CoolParser.AssignTokenContext) {
        printToken("ASSIGN", ctx.lineNum)
    }

    override func enterDarrow(_ ctx: CoolParser.DarrowContext) {
        printToken("DARROW", ctx.lineNum)
    }

    override func enterLe(_ ctx: CoolParser.LeContext) {
        printToken("LE", ctx.lineNum)
    }

    // single character operators

    override func enterSingleChar(_ ctx: CoolParser.SingleCharContext) {
        printToken("'\(ctx.text)'", ctx.lineNum)
    }

    // keywords

    override func enterKeyword(_ ctx: CoolParser.KeywordContext) {
        printToken(ctx.text.uppercased(), ctx.lineNum)
    }

    // identifiers

    override func enterTypeId(_ ctx: CoolParser.TypeIdContext) {
        printToken("TYPEID", ctx)
    }

    override func enterObjectId(_ ctx: CoolParser.ObjectIdContext) {
        printToken("OBJECTID", ctx)
    }

    // errors

    override func enterUnterminatedString(_ ctx: CoolParser.UnterminatedStringContext) {
        let message = ctx.text.last == "\n" ? "Unterminated string constant" : "EOF in string constant"
        printError(message, ctx.lineNum)
    }

    override func enterUnmatchedComment(_ ctx: CoolParser.UnmatchedCommentContext) {
        printError("Unmatched *)", ctx.lineNum)
    }

    override func enterInvalid(_ ctx: CoolParser.InvalidContext) {
        let str: String
        switch ctx.text {
            case "\u{0001}": str = "\001"
            case "\u{0002}": str = "\002"
            case "\u{0003}": str = "\003"
            case "\u{0004}": str = "\004"
            default: str = ""
        }
        printError(str, ctx.lineNum)
    }

    override func enterError(_ ctx: CoolParser.ErrorContext) {
        let message = ctx.text == "\\" ? "\\\\" : ctx.text
        printError(message, ctx.lineNum)
    }
}
