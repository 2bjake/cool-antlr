import Antlr4
import Foundation

enum CompilerError: Error {
    case fileNotFound
    case parseError
    case semanticError
}

func makeParser(for fileName: String) throws -> CoolParser {
    guard let data = FileManager.default.contents(atPath: fileName), let contents = String(data: data, encoding: .utf8) else {
        throw CompilerError.fileNotFound
    }
    let inputStream = ANTLRInputStream(contents)
    let lexer = CoolLexer(inputStream)
    let tokens = CommonTokenStream(lexer)
    return try CoolParser(tokens)
}

func buildProgramTree(parser: CoolParser, fileName: String) throws -> CoolParser.ProgramContext {
    let errorStrategy = PA2ErrorStrategy()
    parser.setErrorHandler(errorStrategy)
    parser.removeErrorListeners()

    let errorListener = PA2ErrorListener(fileName: fileName)
    parser.addErrorListener(errorListener)

    let tree = try parser.program()

    let walker = ParseTreeWalker()
    let syntaxProcessor = SyntaxAnalyzer(fileName: fileName)
    try walker.walk(syntaxProcessor, tree)

    guard errorListener.errorCount == 0 && syntaxProcessor.errorCount == 0 else {
        throw CompilerError.parseError
    }
    return tree
}

func pa1(parser: CoolParser) throws {
    let tree = try parser.allTokens()
    let printer = PA1TokenPrinter()
    try ParseTreeWalker().walk(printer, tree)
}

func pa2(parser: CoolParser, fileName: String) throws {
    let program = try buildProgramTree(parser: parser, fileName: fileName)

    let astBuilder = ASTBuilder(fileName: fileName)
    let ast = astBuilder.build(program)
    let astPrinter = PA2ASTPrinter()
    astPrinter.printTree(ast)
}

func pa3(parser: CoolParser, fileName: String) throws {
    let program = try buildProgramTree(parser: parser, fileName: fileName)
    let astBuilder = ASTBuilder(fileName: fileName)
    var ast = astBuilder.build(program)
    var classAnalyzer = ClassDeclSemanticAnalyzer()
    try classAnalyzer.analyze(ast: &ast)

    let astPrinter = PA2ASTPrinter()
    astPrinter.printTree(ast)
}

enum Program {
    case pa1, pa2, pa3
}

let program: Program = .pa3

func main() {
    guard let fullPath = CommandLine.arguments.dropFirst().first else {
        print("must specify cool file")
        return
    }
    do {
        let parser = try makeParser(for: fullPath)
        let fileName = String(fullPath.split(separator: "/").last!)

        switch program {
            case .pa1: try pa1(parser: parser)
            case .pa2: try pa2(parser: parser, fileName: fileName)
            case .pa3: try pa3(parser: parser, fileName: fileName)
        }
    } catch let error as CompilerError {
        switch error {
            case .fileNotFound:
                errPrint("No file found at \(fullPath)")
            case .parseError:
                errPrint("Compilation halted due to lex and syntax errors")
            case .semanticError:
                errPrint("Compilation halted due to static semantic errors.")
        }
    } catch {
        errPrint("Unexpected error: \(error)")
    }
}

main()
