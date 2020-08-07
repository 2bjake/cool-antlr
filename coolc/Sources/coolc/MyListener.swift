//
//  MyListener.swift
//
//
//  Created by Jake Foster on 8/5/20.
//
import Antlr4
import Foundation

//extension CoolParser.ClassDeclContext {
//    var className: String { TYPEID(0)!.description }
//    var superClassName: String? { TYPEID(1)?.description }
//}
//
//class MyListener: CoolBaseListener {
//
//    override func enterClassDecl(_ ctx: CoolParser.ClassDeclContext) {
//        print("\(ctx.className) inherits from \(ctx.superClassName ?? "Object") and has \(ctx.feature().count ?? 0) features")
//    }
//
//    override func enterAttr(_ ctx: CoolParser.AttrContext) {
//        print("attr named \(ctx.OBJECTID()!) of type \(ctx.TYPEID()!)")
//    }
//
//    override func enterMethod(_ ctx: CoolParser.MethodContext) {
//        print("method named \(ctx.OBJECTID()!)() which returns type \(ctx.TYPEID()!)")
//    }
//}

class MyListener: CoolBaseListener {

    func printToken(_ lineNum: Int, _ symbol: String, _ value: String = "") {
        print("#\(lineNum) \(symbol) \(value)")
    }

    func printError(_ lineNum: Int, _ message: String) {
        printToken(lineNum, "ERROR", "\"\(message)\"")
    }

    // constants

    override func enterInt(_ ctx: CoolParser.IntContext) {
        guard let symbol = ctx.INT()?.getSymbol() else { fatalError() }
        guard let text = symbol.getText() else { fatalError() }
        printToken(symbol.getLine(), "INT_CONST", text)
    }

    func processChar(_ c: Character) -> String {
        switch c {
            case "\n": return "\\n"
            case "\t": return "\\t"
            case "\u{000C}": return "\\f"
            case "\u{0008}": return "\\b"
            default:
                if let asciiVal = c.asciiValue, asciiVal > 0, asciiVal <= 31 {
                    return "\\0\(String(asciiVal, radix: 8))"
                } else {
                    return "\(c)"
                }
        }
    }

    override func enterString(_ ctx: CoolParser.StringContext) {
        guard let symbol = ctx.STRING()?.getSymbol() else { fatalError() }
        guard let rawText = symbol.getText() else { fatalError() }

        // token has start and end double quotes. Strip them off.
        let stripped = rawText.dropFirst().dropLast()

        // TODO: for now, rewrite string for output, later figure out how to persist in tree
        var processed = ""
        var index = stripped.startIndex
        while index != stripped.endIndex {
            let next = stripped.index(after: index)
            if stripped[index] != "\\" {
                processed.append(processChar(stripped[index]))
                index = next
            } else {
                precondition(next != stripped.endIndex)
                switch stripped[next] {
                    case "b", "t", "n", "f", "\\", "\"":
                        processed.append("\\")
                        processed.append(stripped[next])
                    default:
                        processed.append(processChar(stripped[next]))
                }
                index = stripped.index(after: next)
            }
        }
        printToken(symbol.getLine(), "STR_CONST", "\"\(processed)\"")
    }

    override func enterBool(_ ctx: CoolParser.BoolContext) {
        guard let token = ctx.getStart() else { fatalError() }
        guard let text = token.getText()?.lowercased() else { fatalError() }
        printToken(token.getLine(), "BOOL_CONST", text)
    }

    // multi-character operators

    override func enterAssignToken(_ ctx: CoolParser.AssignTokenContext) {
        guard let line = ctx.getStart()?.getLine() else { fatalError() }
        printToken(line, "ASSIGN")
    }

    override func enterDarrow(_ ctx: CoolParser.DarrowContext) {
        guard let line = ctx.getStart()?.getLine() else { fatalError() }
        printToken(line, "DARROW")
    }

    override func enterLe(_ ctx: CoolParser.LeContext) {
        guard let line = ctx.getStart()?.getLine() else { fatalError() }
        printToken(line, "LE")
    }

    // single character operators

    override func enterSingleChar(_ ctx: CoolParser.SingleCharContext) {
        guard let token = ctx.getStart() else { fatalError() }
        printToken(token.getLine(), "'\(token.getText()!)'")
    }

    // keywords

    override func enterKeyword(_ ctx: CoolParser.KeywordContext) {
        guard let token = ctx.getStart() else { fatalError() }
        guard let text = token.getText()?.uppercased() else { fatalError() }
        printToken(token.getLine(), text)
    }

    // identifiers

    override func enterTypeid(_ ctx: CoolParser.TypeidContext) {
        guard let symbol = ctx.TYPEID()?.getSymbol() else { fatalError() }
        guard let text = symbol.getText() else { fatalError() }
        printToken(symbol.getLine(), "TYPEID", text)
    }

    override func enterObjectid(_ ctx: CoolParser.ObjectidContext) {
        guard let symbol = ctx.OBJECTID()?.getSymbol() else { fatalError() }
        guard let text = symbol.getText() else { fatalError() }
        printToken(symbol.getLine(), "OBJECTID", text)
    }

    // errors

    override func enterUnterminatedString(_ ctx: CoolParser.UnterminatedStringContext) {
        guard let token = ctx.getStart() else { fatalError() }
        if token.getText()?.last == "\n" {
            printError(token.getLine(), "Unterminated string constant")
        } else {
            printError(token.getLine(), "EOF in string constant")
        }
    }

    override func enterUnmatchedComment(_ ctx: CoolParser.UnmatchedCommentContext) {
        guard let token = ctx.getStart() else { fatalError() }
        printError(token.getLine(), "Unmatched *)")
    }

    override func enterInvalid(_ ctx: CoolParser.InvalidContext) {
        guard let token = ctx.getStart() else { fatalError() }
        let str: String
        switch token.getText() {
            case "\u{0001}": str = "\001"
            case "\u{0002}": str = "\002"
            case "\u{0003}": str = "\003"
            case "\u{0004}": str = "\004"
            default: str = ""
        }
        printError(token.getLine(), str)
    }

    override func enterError(_ ctx: CoolParser.ErrorContext) {
        guard let token = ctx.getStart() else { fatalError() }
        guard var text = token.getText() else { fatalError() }
        if text == "\\" {
            text = text + text
        }
        printError(token.getLine(), text)
    }
}
