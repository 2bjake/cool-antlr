//
//  Printer.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

private struct Indention: CustomStringConvertible {
    var description = ""

    mutating func inc() {
        description += "  "
    }

    mutating func dec() {
        description = String(description.dropLast(2))
    }
}

class Printer {
    private var indention = Indention()
    var printTypeNames = true // this is only for PA2 grading, eventually it can be removed

    func indent() { indention.inc() }
    func dedent() { indention.dec() }

    typealias Printable = PA2Named & SourceLocated

    static func lineString(_ located: SourceLocated) -> String {
        return "#\(located.location.lineNumber)"
    }

    func printElements(_ strings: CustomStringConvertible...) {
        strings.forEach { print("\(indention)\($0)") }
    }

    private func printHeader(_ printable: Printable) {
        printElements(Self.lineString(printable), printable.pa2Name)
    }

    func printTypeName(_ node: ExprNode) {
        let type = printTypeNames ? node.type : .none

        printElements(": \(type)")
    }

    // print Printable object details without a type string
    func printObject(_ printable: Printable, _ internalsPrinter: () -> Void) {
        printHeader(printable)
        indention.inc()
        internalsPrinter()
        indention.dec()
    }

    func printObject(_ printable: Printable, elements: CustomStringConvertible...) {
        printObject(printable) {
            for element in elements {
                printElements(element)
            }
        }
    }

    // print Node object details with a type string
    func printNode(_ node: ExprNode, _ internalsPrinter: () -> Void) {
        printObject(node, internalsPrinter)
        printTypeName(node)
    }

    func printNode(_ node: ExprNode, elements: CustomStringConvertible...) {
        printNode(node) {
            for element in elements {
                printElements(element)
            }
        }
    }
}
