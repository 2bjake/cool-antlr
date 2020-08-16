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

func makeErrorMsg(at location: String) -> String {
    return "syntax error at or near \(location)"
}

// formats error messages in a form that PA2 grading scripts expect
class PA2ErrorStrategy: DefaultErrorStrategy {
    private var badTokenIndices = Set<Int>()

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
    public private(set) var hasError = false

    private let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    private func printError(_ msg: String, _ line: Int) {
        errPrint("\"\(fileName)\", line \(line): \(msg)")
    }

    override public func syntaxError<T>(_: Recognizer<T>, _: AnyObject?, _ line: Int, _: Int, _ msg: String, _: AnyObject?) {
        hasError = true
        if Parser.ConsoleError {
            printError(msg, line)
        }
    }
}
