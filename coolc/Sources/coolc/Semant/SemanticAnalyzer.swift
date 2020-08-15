//
//  SemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

struct SemanticAnalyzer {
    var classAnalyzer = ClassDeclAnalyzer()

    mutating func analyze(program: inout ProgramNode) throws {
        let (allTypes, objectClass) = try classAnalyzer.analyze(ast: &program)
        var featureAnalyzer = ClassFeatureAnalyzer(program: program, allTypes: allTypes, objectClass: objectClass)
        try featureAnalyzer.analyze()
    }
}
