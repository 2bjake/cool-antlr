//
//  ClassType.swift
//
//
//  Created by Jake Foster on 8/12/20.
//

enum ClassType {
    case none
    case selfType
    case object
    case io
    case bool
    case int
    case string
    case main
    case defined(IdSymbol)
}

extension ClassType {
    static let constantTypes = [ClassType.bool, .string, .int]
    static let builtInTypes = [ClassType.object, .int, .bool, .string, .io]
    var isBuiltInClass: Bool { Self.builtInTypes.contains(self) }
    var isInheritable: Bool { !Self.constantTypes.contains(self) }
}

extension ClassType: CustomStringConvertible {
    init(_ id: IdSymbol) {
        switch id {
            case .selfTypeName: self = .selfType
            case .objectTypeName: self = .object
            case .ioTypeName: self = .io
            case .boolTypeName: self = .bool
            case .intTypeName: self = .int
            case .stringTypeName: self = .string
            case .mainTypeName: self = .main
            default:
                precondition(id.value.first?.isUppercase == true)
                self = .defined(id)
        }
    }

    var description: String {
        switch self {
            case .none: return IdSymbol.noClass.value
            case .selfType: return IdSymbol.selfTypeName.value
            case .object: return IdSymbol.objectTypeName.value
            case .io: return IdSymbol.ioTypeName.value
            case .bool: return IdSymbol.boolTypeName.value
            case .int: return IdSymbol.intTypeName.value
            case .string: return IdSymbol.stringTypeName.value
            case .main: return IdSymbol.mainTypeName.value
            case .defined(let id): return id.value
        }
    }
}

extension ClassType: Hashable, Equatable {}
