//
//  SymbolTable.swift
//
//
//  Created by Jake Foster on 8/12/20.
//

struct SymbolTable<Data> {
    private typealias SymbolMap = [IdSymbol: Data]
    private var scopes: [SymbolMap] = []

    mutating func enterScope() {
        scopes.append([:])
    }

    mutating func exitScope() {
        _ = scopes.popLast()
    }

    func lookup(_ id: IdSymbol) -> Data? {
        let remainingScopes = scopes.reversed().drop(while: { $0[id] == nil })
        return remainingScopes.first?[id]
    }

    func probe(_ id: IdSymbol) -> Data? {
        scopes.last?[id]
    }

    mutating func insert(id: IdSymbol, data: Data) {
        if scopes.isEmpty {
            enterScope()
        }
        scopes[scopes.count - 1][id] = data
    }
}
