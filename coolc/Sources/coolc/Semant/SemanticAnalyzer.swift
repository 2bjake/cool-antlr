//
//  SemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

struct SemanticAnalyzer {
    var classAnalyzer = ClassDeclAnalyzer()

    mutating func analyze(program: inout ProgramNode) throws {
        let (allClasses, objectClass) = try classAnalyzer.analyze(ast: &program)
        var featureAnalyzer = ClassFeatureAnalyzer(program: program, classes: allClasses, objectClass: objectClass)
        try featureAnalyzer.analyze()
    }
}
