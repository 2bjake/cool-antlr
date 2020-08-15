//
//  PA2Named.swift
//
//
//  Created by Jake Foster on 8/9/20.
//

// Provides a name that is expected by PA2 grading scripts
protocol PA2Named {
    var pa2Name: String { get }
}

extension ArithOp: PA2Named {
    var pa2Name: String {
        switch self {
            case .plus: return "_plus"
            case .sub: return "_sub"
            case .mul: return "_mul"
            case .div: return "_divide"
        }
    }
}

extension CompOp: PA2Named {
    var pa2Name: String {
        switch self {
            case .eq: return "_eq"
            case .lt: return "_lt"
            case .le: return "_leq"
        }
    }
}

extension ProgramNode: PA2Named {
    var pa2Name: String { "_program" }
}

extension ClassNode: PA2Named {
    var pa2Name: String { "_class" }
}

extension AttributeNode: PA2Named {
    var pa2Name: String { "_attr" }
}

extension MethodNode: PA2Named {
    var pa2Name: String { "_method" }
}

extension LoopExprNode: PA2Named {
    var pa2Name: String { "_loop" }
}

extension NotExprNode: PA2Named {
    var pa2Name: String { "_comp" }
}

extension BoolExprNode: PA2Named {
    var pa2Name: String { "_bool" }
}

extension StringExprNode: PA2Named {
    var pa2Name: String { "_String" }
}

extension IntExprNode: PA2Named {
    var pa2Name: String { "_int" }
}

extension BlockExprNode: PA2Named {
    var pa2Name: String { "_block" }
}

extension NegateExprNode: PA2Named {
    var pa2Name: String { "_neg" }
}

extension ObjectExprNode: PA2Named {
    var pa2Name: String { "_object" }
}

extension IsvoidExprNode: PA2Named {
    var pa2Name: String { "_isvoid" }
}

extension LetExprNode: PA2Named {
    var pa2Name: String { "_let" }
}

extension AssignExprNode: PA2Named {
    var pa2Name: String { "_assign" }
}

extension ConditionalExprNode: PA2Named {
    var pa2Name: String { "_cond" }
}

extension NewExprNode: PA2Named {
    var pa2Name: String { "_new" }
}

extension DispatchExprNode: PA2Named {
    var pa2Name: String { isStaticDispatch ? "_static_dispatch" : "_dispatch" }
}

extension CaseExprNode: PA2Named {
    var pa2Name: String { "_typcase" }
}

extension Branch: PA2Named {
    var pa2Name: String { "_branch" }
}

extension Formal: PA2Named {
    var pa2Name: String { "_formal" }
}

extension ArithExprNode: PA2Named {
    var pa2Name: String { op.pa2Name }
}

extension CompareExprNode: PA2Named {
    var pa2Name: String { op.pa2Name }
}

extension NoExprNode: PA2Named {
    var pa2Name: String { "_no_expr" }
}
