//
//  PA2ErrorStrategy.swift
//
//
//  Created by Jake Foster on 8/7/20.
//

import Antlr4
import Foundation

func errPrint(_ msg: String) {
    fputs(msg + "\n", stderr)
}

func makeErrorMsg(at location: String) -> String{
    return "syntax error at or near \(location)"
}


func printError(_ msg: String, _ line: Int) {
    errPrint("filename, line \(line): \(msg)")
}

class PA2ErrorStrategy : DefaultErrorStrategy {
    var badTokenIndices = Set<Int>()

    private func isNewToken(_ token: Token) -> Bool {
        return badTokenIndices.insert(token.getTokenIndex()).inserted
    }

    override func reportInputMismatch(_ recognizer: Parser, _ e: InputMismatchException) {
        let token = e.getOffendingToken()
        guard isNewToken(token) else { return }
        let msg = makeErrorMsg(at: getTokenErrorDisplay(token))
        recognizer.notifyErrorListeners(token, msg, e)
    }

    override func reportUnwantedToken(_ recognizer: Parser) {
        guard !inErrorRecoveryMode(recognizer) else { return }
        beginErrorCondition(recognizer)

        guard let token = try? recognizer.getCurrentToken(), isNewToken(token) else { return }
        let msg = makeErrorMsg(at: getTokenErrorDisplay(token))
        recognizer.notifyErrorListeners(token, msg, nil)
    }

    override func reportMissingToken(_ recognizer: Parser) {
        guard !inErrorRecoveryMode(recognizer) else { return }
        beginErrorCondition(recognizer)

        guard let token = try? recognizer.getCurrentToken(), isNewToken(token) else { return }
        let msg = makeErrorMsg(at: getTokenErrorDisplay(token))
        recognizer.notifyErrorListeners(token, msg, nil)
    }
}

class PA2ErrorListener: BaseErrorListener {
    public var errorCount = 0

    override public func syntaxError<T>(_ recognizer: Recognizer<T>, _ offendingSymbol: AnyObject?, _ line: Int, _ charPositionInLine: Int, _ msg: String, _ e: AnyObject?) {
        errorCount += 1
        if Parser.ConsoleError {
            printError(msg, line)
        }
    }
}

