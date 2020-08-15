//
//  IdSymbol.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

// common symbols
extension IdSymbol {
    static let selfName = idTable.add("self")
    static let mainMethod = idTable.add("main")

    // class type names
    static let selfTypeName = idTable.add("SELF_TYPE")
    static let objectTypeName = idTable.add("Object")
    static let boolTypeName = idTable.add("Bool")
    static let stringTypeName = idTable.add("String")
    static let intTypeName = idTable.add("Int")
    static let ioTypeName = idTable.add("IO")
    static let mainTypeName = idTable.add("Main")

    // runtime methods/formals
    static let arg = idTable.add("arg")
    static let arg2 = idTable.add("arg2")
    static let concat = idTable.add("concat")
    static let abort = idTable.add("abort")
    static let copy = idTable.add("copy")
    static let inInt = idTable.add("in_int")
    static let inString = idTable.add("in_string")
    static let length = idTable.add("length")
    static let noType = idTable.add("_no_type")
    static let outInt = idTable.add("out_int")
    static let outString = idTable.add("out_string")
    static let primSlot = idTable.add("_prim_slot")
    static let strField = idTable.add("_str_field")
    static let substr = idTable.add("substr")
    static let typeName = idTable.add("type_name")
    static let val = idTable.add("_val")
}
