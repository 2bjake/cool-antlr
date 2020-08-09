import Antlr4
import Foundation

func pa1(_ args: [String]) throws {
    guard let fileName = args.dropFirst().first else {
        print("must specify cool file")
        return
    }
    guard let data = FileManager.default.contents(atPath: fileName), let contents = String(data: data, encoding: .utf8) else {
        print("No file found at \(fileName)")
        return
    }

    let inputStream = ANTLRInputStream(contents)
    let lexer = CoolLexer(inputStream)
    let tokens = CommonTokenStream(lexer)
    let parser = try! CoolParser(tokens)
    let tree = try! parser.allTokens()

    let walker = ParseTreeWalker()
    let printer = TokenPrinter()
    try! walker.walk(printer, tree)
}

func pa2(_ args: [String]) throws {
    guard let fileName = args.dropFirst().first else {
        print("must specify cool file")
        return
    }
    guard let data = FileManager.default.contents(atPath: fileName), let contents = String(data: data, encoding: .utf8) else {
        print("No file found at \(fileName)")
        return
    }

    let inputStream = ANTLRInputStream(contents)
    let lexer = CoolLexer(inputStream)
    let tokens = CommonTokenStream(lexer)
    let parser = try! CoolParser(tokens)
    let errorStrategy = PA2ErrorStrategy()
    parser.setErrorHandler(errorStrategy)
    parser.removeErrorListeners()

    let errorListener = PA2ErrorListener()
    parser.addErrorListener(errorListener)

    let tree = try! parser.program()

    let walker = ParseTreeWalker()
    let syntaxProcessor = SyntaxProcessor()
    try! walker.walk(syntaxProcessor, tree)

    guard errorListener.errorCount == 0 && syntaxProcessor.errorCount == 0 else {
        errPrint("Compilation halted due to lex and syntax errors")
        return
    }

    let file = String(fileName.split(separator: "/").last!)
    let printer = TreePrinter(fileName: file)
    printer.visit(tree)
}

func pa3(_ args: [String]) throws {
    guard let fileName = args.dropFirst().first else {
        print("must specify cool file")
        return
    }
    guard let data = FileManager.default.contents(atPath: fileName), let contents = String(data: data, encoding: .utf8) else {
        print("No file found at \(fileName)")
        return
    }

    let inputStream = ANTLRInputStream(contents)
    let lexer = CoolLexer(inputStream)
    let tokens = CommonTokenStream(lexer)
    let parser = try! CoolParser(tokens)
    let errorStrategy = PA2ErrorStrategy()
    parser.setErrorHandler(errorStrategy)
    parser.removeErrorListeners()

    let errorListener = PA2ErrorListener()
    parser.addErrorListener(errorListener)

    let tree = try! parser.program()

    let walker = ParseTreeWalker()
    let syntaxProcessor = SyntaxProcessor()
    try! walker.walk(syntaxProcessor, tree)

    guard errorListener.errorCount == 0 && syntaxProcessor.errorCount == 0 else {
        errPrint("Compilation halted due to lex and syntax errors")
        return
    }

    let file = String(fileName.split(separator: "/").last!)

    let semanticAnalyzer = SemanticAnalyzer(fileName: file)

    try! walker.walk(semanticAnalyzer, tree)

    guard semanticAnalyzer.errorCount == 0 else {
        errPrint("Compilation halted due to static semantic errors.")
        return
    }


    let printer = TreePrinter(fileName: file)
    printer.visit(tree)
}

do {
    try pa2(CommandLine.arguments)
} catch (let e) {
    print("Program failed with error: \(e)")
}
