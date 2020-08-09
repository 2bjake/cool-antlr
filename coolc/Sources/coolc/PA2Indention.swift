//
//  PA2Indention.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

struct PA2Indention: CustomStringConvertible {
    var description = ""

    mutating func inc() {
        description += "  "
    }

    mutating func dec() {
        description = String(description.dropLast(2))
    }

}
