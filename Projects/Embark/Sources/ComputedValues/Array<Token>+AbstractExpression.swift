import Foundation

indirect enum Expression: Equatable {
    case binary(operator: BinaryOperator, left: Expression?, right: Expression?)
    case string(constant: String)
    case number(constant: Double)
    case store(key: String)

    var `operator`: BinaryOperator? {
        switch self {
        case let .binary(op, _, _):
            return op
        default:
            return nil
        }
    }

    var left: Expression? {
        switch self {
        case let .binary(_, left, _):
            return left
        default:
            return nil
        }
    }

    func evaluate(store: EmbarkStore) -> String? {
        switch self {
        case let .binary(op, left, right):
            switch op {
            case .addition:
                return String((Double(left?.evaluate(store: store) ?? "") ?? 0) + (Double(right?.evaluate(store: store) ?? "") ?? 0))
            case .subtraction:
                return String((Double(left?.evaluate(store: store) ?? "") ?? 0) - (Double(right?.evaluate(store: store) ?? "") ?? 0))
            case .concatenation:
                return (left?.evaluate(store: store) ?? "") + (right?.evaluate(store: store) ?? "")
            }
        case let .string(constant: constant):
            return constant
        case let .number(constant: constant):
            return String(constant)
        case let .store(key: key):
            return store.getValue(key: key)
        }
    }
}

extension Array where Element == Token {
    var expression: Expression? {
        reduce(nil) { (prevExpression, token) -> Expression? in
            switch token {
            case .void:
                return prevExpression
            case let .binaryOperator(operator: op):
                if prevExpression == nil {
                    fatalError("Unexpected token operator: \(op)")
                }

                return .binary(operator: op, left: prevExpression, right: nil)
            case let .storeKey(key: key):
                let storeKeyExpression = Expression.store(key: key)

                if let op = prevExpression?.operator, let left = prevExpression?.left {
                    return .binary(operator: op, left: left, right: storeKeyExpression)
                }

                return storeKeyExpression
            case let .stringConstant(constant: constant):
                let stringConstantExpression = Expression.string(constant: constant)

                if let op = prevExpression?.operator, let left = prevExpression?.left {
                    return .binary(operator: op, left: left, right: stringConstantExpression)
                }

                return stringConstantExpression
            case let .numberConstant(constant: constant):
                let numberConstantExpression = Expression.number(constant: constant)

                if let op = prevExpression?.operator, let left = prevExpression?.left {
                    return .binary(operator: op, left: left, right: numberConstantExpression)
                }

                return numberConstantExpression
            }
        }
    }
}
