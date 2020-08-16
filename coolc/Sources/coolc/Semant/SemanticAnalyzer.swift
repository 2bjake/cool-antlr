//
//  SemanticAnalyzer.swift
//
//
//  Created by Jake Foster on 8/13/20.
//

enum SemanticAnalyzer {
    static func analyze(program: inout ProgramNode) throws {
        var classAnalyzer = ClassDeclAnalyzer()
        let (allClasses, objectClass) = try classAnalyzer.analyze(ast: &program)

        var featureAnalyzer = ClassFeatureAnalyzer(program: program, classes: allClasses, objectClass: objectClass)

        featureAnalyzer.typeChecker = {
            ClassTypeChecker(classNode: $0, objectTypeTable: $1, classes: $2).check()
        }

        try featureAnalyzer.analyze()
    }
}
