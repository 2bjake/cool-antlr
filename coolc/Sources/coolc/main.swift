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
    try! walker.walk(syntaxProcessor, tree)

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
    let tree = try buildProgramTree(parser: parser, fileName: fileName)
    let printer = PA2AntlrTreePrinter(fileName: fileName)
    printer.visit(tree)
}

func pa2AST(parser: CoolParser, fileName: String) throws {
    let tree = try buildProgramTree(parser: parser, fileName: fileName)

    let astBuilder = ASTBuilder(fileName: fileName)
    let ast = try astBuilder.start(tree)
    let astPrinter = PA2ASTPrinter()
    astPrinter.printTree(ast)
}

func pa3(parser: CoolParser, fileName: String) throws {
    let tree = try buildProgramTree(parser: parser, fileName: fileName)

    let semanticAnalyzer = SemanticAnalyzer(fileName: fileName)
    try ParseTreeWalker().walk(semanticAnalyzer, tree)

    guard semanticAnalyzer.errorCount == 0 else {
        throw CompilerError.semanticError
    }

    let printer = PA2AntlrTreePrinter(fileName: fileName)
    printer.visit(tree)
}

func pa3AST(parser: CoolParser, fileName: String) throws {
    let tree = try buildProgramTree(parser: parser, fileName: fileName)
    let astBuilder = ASTBuilder(fileName: fileName)
    let ast = try astBuilder.start(tree)
    let astPrinter = PA2ASTPrinter()
    astPrinter.printTree(ast)
}

enum Program {
    case pa1, pa2, pa2AST, pa3, pa3AST
}

let program: Program = .pa3AST

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
            case .pa2AST: try pa2AST(parser: parser, fileName: fileName)
            case .pa3: try pa3(parser: parser, fileName: fileName)
            case .pa3AST: try pa3AST(parser: parser, fileName: fileName)
        }
    } catch (let e as CompilerError) {
        switch e {
            case .fileNotFound:
                errPrint("No file found at \(fullPath)")
            case .parseError:
                errPrint("Compilation halted due to lex and syntax errors")
            case .semanticError:
                errPrint("Compilation halted due to static semantic errors.")
        }
    } catch(let e) {
        errPrint("Unexpected error: \(e)")
    }
}

main()
