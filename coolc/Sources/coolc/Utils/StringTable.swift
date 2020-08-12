//
//  StringTable.swift
//
//
//  Created by Jake Foster on 8/12/20.
//

struct Symbol<T> {
    let id: Int
    let value: String

    fileprivate init(id: Int, value: String) {
        self.id = id
        self.value = value
    }
}

extension Symbol: Hashable, Equatable {}

extension Symbol: CustomStringConvertible {
    var description: String { value }
}

enum IdEntry {}
enum StringEntry {}
enum IntEntry {}

typealias IdSymbol = Symbol<IdEntry>
typealias StringSymbol = Symbol<StringEntry>
typealias IntSymbol = Symbol<IntEntry>

class StringTable<T> {
    private var nextId: Int = 0
    private var stringToSymbol: [String: Symbol<T>] = [:]

    fileprivate init() {}

    func add(_ str: String) -> Symbol<T> {
        if let symbol = stringToSymbol[str] {
            return symbol
        } else {
            let symbol = Symbol<T>(id: nextId, value: str)
            stringToSymbol[str] = symbol
            nextId += 1
            return symbol
        }
    }
}

let idTable = StringTable<IdEntry>()
let stringTable = StringTable<StringEntry>()
let intTable = StringTable<IntEntry>()
