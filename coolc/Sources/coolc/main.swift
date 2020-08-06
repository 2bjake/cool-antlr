import Antlr4
import Foundation

func main(_ args: [String]) throws {
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
    let listener = MyListener()
    try! walker.walk(listener, tree)
}

do {
    try main(CommandLine.arguments)
} catch (let e) {
    print("Program failed with error: \(e)")
}
