//
//  ASTVisitor.swift
//
//
//  Created by Jake Foster on 8/11/20.
//

protocol ASTVisitor {
    func visit(_ node: Node)
    func visit(_ node: ProgramNode)
    func visit(_ node: ClassNode)
    func visit(_ node: AttributeNode)
    func visit(_ node: MethodNode)
    func visit(_ node: NoExprNode)
    func visit(_ node: BoolExprNode)
    func visit(_ node: StringExprNode)
    func visit(_ node: IntExprNode)
    func visit(_ node: NegateExprNode)
    func visit(_ node: IsvoidExprNode)
    func visit(_ node: DispatchExprNode)
    func visit(_ node: ArithExprNode)
    func visit(_ node: CompareExprNode)
    func visit(_ node: NotExprNode)
    func visit(_ node: AssignExprNode)
    func visit(_ node: ObjectExprNode)
    func visit(_ node: NewExprNode)
    func visit(_ node: ConditionalExprNode)
    func visit(_ node: LoopExprNode)
    func visit(_ node: CaseExprNode)
    func visit(_ node: BlockExprNode)
    func visit(_ node: LetExprNode)
    func visit(_ node: ExprNode)
    func visitChildren(_ node: Node)
}

extension ASTVisitor {
    func visitChildren(_ node: Node) {
        node.children.forEach { $0.accept(self) }
    }
}

extension ASTVisitor {
    func visit(_ node: Node) {
        switch node {
            case let node as ProgramNode: visit(node)
            case let node as ClassNode: visit(node)
            case let node as AttributeNode: visit(node)
            case let node as MethodNode: visit(node)
            case let node as ExprNode: visit(node)
            default: fatalError("visit called on unsupported Node \(type(of: node))")
        }
    }


    // swiftlint:disable cyclomatic_complexity
    func visit(_ node: ExprNode) {
        switch node {
            case let node as NoExprNode: visit(node)
            case let node as BoolExprNode: visit(node)
            case let node as StringExprNode: visit(node)
            case let node as IntExprNode: visit(node)
            case let node as NegateExprNode: visit(node)
            case let node as IsvoidExprNode: visit(node)
            case let node as DispatchExprNode: visit(node)
            case let node as ArithExprNode: visit(node)
            case let node as CompareExprNode: visit(node)
            case let node as NotExprNode: visit(node)
            case let node as AssignExprNode: visit(node)
            case let node as ObjectExprNode: visit(node)
            case let node as NewExprNode: visit(node)
            case let node as ConditionalExprNode: visit(node)
            case let node as LoopExprNode: visit(node)
            case let node as CaseExprNode: visit(node)
            case let node as BlockExprNode: visit(node)
            case let node as LetExprNode: visit(node)
            default: fatalError("visit called on unsupported Node \(type(of: node))")
        }
    }
}
