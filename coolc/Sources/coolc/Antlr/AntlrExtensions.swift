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

extension TerminalNode {
    func getIdSymbol() -> IdSymbol {
        idTable.add(getText())
    }

    func getIntSymbol() -> IntSymbol {
        intTable.add(getText())
    }

    private func processChar(_ char: Character) -> String {
        switch char {
            case "\n": return "\\n"
            case "\t": return "\\t"
            case "\u{000C}": return "\\f"
            case "\u{0008}": return "\\b"
            default:
                if let asciiVal = char.asciiValue, asciiVal > 0, asciiVal <= 31 {
                    return "\\0\(String(asciiVal, radix: 8))"
                } else {
                    return "\(char)"
                }
        }
    }

    private func processString(_ str: String) -> String{
        // token has start and end double quotes. Strip them off.
        let stripped = str.dropFirst().dropLast()

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
        return processed
    }

    func getStringSymbol() -> StringSymbol {
        stringTable.add(processString(getText()))
    }
}
