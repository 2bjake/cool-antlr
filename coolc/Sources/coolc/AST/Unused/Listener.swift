//
//  Listener.swift
//
//
//  Created by Jake Foster on 8/13/20.
//
/*
protocol Listener {
    func enter(_ node: Node)
    func enter(_ node: ProgramNode)
    func enter(_ node: ClassNode)
    func enter(_ node: AttributeNode)
    func enter(_ node: MethodNode)
    func enter(_ node: NoExprNode)
    func enter(_ node: BoolExprNode)
    func enter(_ node: StringExprNode)
    func enter(_ node: IntExprNode)
    func enter(_ node: NegateExprNode)
    func enter(_ node: IsvoidExprNode)
    func enter(_ node: DispatchExprNode)
    func enter(_ node: ArithExprNode)
    func enter(_ node: CompareExprNode)
    func enter(_ node: NotExprNode)
    func enter(_ node: AssignExprNode)
    func enter(_ node: ObjectExprNode)
    func enter(_ node: NewExprNode)
    func enter(_ node: ConditionalExprNode)
    func enter(_ node: LoopExprNode)
    func enter(_ node: CaseExprNode)
    func enter(_ node: BlockExprNode)
    func enter(_ node: LetExprNode)
    func enter(_ node: ExprNode)

    func exit(_ node: Node)
    func exit(_ node: ProgramNode)
    func exit(_ node: ClassNode)
    func exit(_ node: AttributeNode)
    func exit(_ node: MethodNode)
    func exit(_ node: NoExprNode)
    func exit(_ node: BoolExprNode)
    func exit(_ node: StringExprNode)
    func exit(_ node: IntExprNode)
    func exit(_ node: NegateExprNode)
    func exit(_ node: IsvoidExprNode)
    func exit(_ node: DispatchExprNode)
    func exit(_ node: ArithExprNode)
    func exit(_ node: CompareExprNode)
    func exit(_ node: NotExprNode)
    func exit(_ node: AssignExprNode)
    func exit(_ node: ObjectExprNode)
    func exit(_ node: NewExprNode)
    func exit(_ node: ConditionalExprNode)
    func exit(_ node: LoopExprNode)
    func exit(_ node: CaseExprNode)
    func exit(_ node: BlockExprNode)
    func exit(_ node: LetExprNode)
    func exit(_ node: ExprNode)
}

extension Listener {
    func enter(_ node: Node) {
        switch node {
            case let node as ProgramNode: enter(node)
            case let node as ClassNode: enter(node)
            case let node as AttributeNode: enter(node)
            case let node as MethodNode: enter(node)
            case let node as ExprNode: enter(node)
            default: fatalError("enter called on unsupported Node \(type(of: node))")
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func enter(_ node: ExprNode) {
        switch node {
            case let node as NoExprNode: enter(node)
            case let node as BoolExprNode: enter(node)
            case let node as StringExprNode: enter(node)
            case let node as IntExprNode: enter(node)
            case let node as NegateExprNode: enter(node)
            case let node as IsvoidExprNode: enter(node)
            case let node as DispatchExprNode: enter(node)
            case let node as ArithExprNode: enter(node)
            case let node as CompareExprNode: enter(node)
            case let node as NotExprNode: enter(node)
            case let node as AssignExprNode: enter(node)
            case let node as ObjectExprNode: enter(node)
            case let node as NewExprNode: enter(node)
            case let node as ConditionalExprNode: enter(node)
            case let node as LoopExprNode: enter(node)
            case let node as CaseExprNode: enter(node)
            case let node as BlockExprNode: enter(node)
            case let node as LetExprNode: enter(node)
            default: fatalError("enter called on unsupported Node \(type(of: node))")
        }
    }
}

extension Listener {
    func exit(_ node: Node) {
        switch node {
            case let node as ProgramNode: exit(node)
            case let node as ClassNode: exit(node)
            case let node as AttributeNode: exit(node)
            case let node as MethodNode: exit(node)
            case let node as ExprNode: exit(node)
            default: fatalError("exit called on unsupported Node \(type(of: node))")
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func exit(_ node: ExprNode) {
        switch node {
            case let node as NoExprNode: exit(node)
            case let node as BoolExprNode: exit(node)
            case let node as StringExprNode: exit(node)
            case let node as IntExprNode: exit(node)
            case let node as NegateExprNode: exit(node)
            case let node as IsvoidExprNode: exit(node)
            case let node as DispatchExprNode: exit(node)
            case let node as ArithExprNode: exit(node)
            case let node as CompareExprNode: exit(node)
            case let node as NotExprNode: exit(node)
            case let node as AssignExprNode: exit(node)
            case let node as ObjectExprNode: exit(node)
            case let node as NewExprNode: exit(node)
            case let node as ConditionalExprNode: exit(node)
            case let node as LoopExprNode: exit(node)
            case let node as CaseExprNode: exit(node)
            case let node as BlockExprNode: exit(node)
            case let node as LetExprNode: exit(node)
            default: fatalError("exit called on unsupported Node \(type(of: node))")
        }
    }
}

class BaseListener: Listener {
    func enter(_ node: ProgramNode) {}
    func enter(_ node: ClassNode) {}
    func enter(_ node: AttributeNode) {}
    func enter(_ node: MethodNode) {}
    func enter(_ node: NoExprNode) {}
    func enter(_ node: BoolExprNode) {}
    func enter(_ node: StringExprNode) {}
    func enter(_ node: IntExprNode) {}
    func enter(_ node: NegateExprNode) {}
    func enter(_ node: IsvoidExprNode) {}
    func enter(_ node: DispatchExprNode) {}
    func enter(_ node: ArithExprNode) {}
    func enter(_ node: CompareExprNode) {}
    func enter(_ node: NotExprNode) {}
    func enter(_ node: AssignExprNode) {}
    func enter(_ node: ObjectExprNode) {}
    func enter(_ node: NewExprNode) {}
    func enter(_ node: ConditionalExprNode) {}
    func enter(_ node: LoopExprNode) {}
    func enter(_ node: CaseExprNode) {}
    func enter(_ node: BlockExprNode) {}
    func enter(_ node: LetExprNode) {}
    func enter(_ node: ExprNode) {}

    func exit(_ node: ProgramNode) {}
    func exit(_ node: ClassNode) {}
    func exit(_ node: AttributeNode) {}
    func exit(_ node: MethodNode) {}
    func exit(_ node: NoExprNode) {}
    func exit(_ node: BoolExprNode) {}
    func exit(_ node: StringExprNode) {}
    func exit(_ node: IntExprNode) {}
    func exit(_ node: NegateExprNode) {}
    func exit(_ node: IsvoidExprNode) {}
    func exit(_ node: DispatchExprNode) {}
    func exit(_ node: ArithExprNode) {}
    func exit(_ node: CompareExprNode) {}
    func exit(_ node: NotExprNode) {}
    func exit(_ node: AssignExprNode) {}
    func exit(_ node: ObjectExprNode) {}
    func exit(_ node: NewExprNode) {}
    func exit(_ node: ConditionalExprNode) {}
    func exit(_ node: LoopExprNode) {}
    func exit(_ node: CaseExprNode) {}
    func exit(_ node: BlockExprNode) {}
    func exit(_ node: LetExprNode) {}
    func exit(_ node: ExprNode) {}
}
*/
