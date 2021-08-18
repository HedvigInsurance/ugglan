import Foundation

struct TokenCheckers {
    static var void: NSRegularExpression { try! NSRegularExpression(pattern: "^\\s+", options: []) }

    static var binaryOperator: NSRegularExpression {
        try! NSRegularExpression(pattern: "^(-|\\+\\+|\\+)", options: [])
    }

    static var storeKey: NSRegularExpression {
        try! NSRegularExpression(pattern: "^([a-zA-Z][\\w\\d]*)", options: [.caseInsensitive])
    }

    static var stringConstantDoubleQuotes: NSRegularExpression {
        try! NSRegularExpression(pattern: "^\"([^\"]*)\"", options: [])
    }

    static var stringConstantSingleQuotes: NSRegularExpression {
        try! NSRegularExpression(pattern: "^'([^']*)'", options: [])
    }

    static var numberConstant: NSRegularExpression {
        try! NSRegularExpression(pattern: "^(\\d+(\\.\\d+)?)", options: [])
    }

    typealias Matchers = [NSRegularExpression: (_ range: NSRange, _ string: String) -> Token]

    static var matchers: Matchers {
        var matchers: Matchers = [:]

        matchers[binaryOperator] = { range, string in
            guard let swiftRange = Range(range, in: string) else { fatalError("Failed to parse range") }
            guard let binaryOperator = BinaryOperator(rawValue: String(string[swiftRange])) else {
                fatalError("Non valid binary operator")
            }
            return .binaryOperator(operator: binaryOperator)
        }

        matchers[storeKey] = { range, string in
            guard let swiftRange = Range(range, in: string) else { fatalError("Failed to parse range") }
            return .storeKey(key: String(string[swiftRange]))
        }

        matchers[stringConstantDoubleQuotes] = { range, string in
            guard let swiftRange = Range(range, in: string) else { fatalError("Failed to parse range") }

            var constant = String(string[swiftRange])
            constant.removeFirst()
            constant.removeLast()

            return .stringConstant(constant: constant)
        }

        matchers[stringConstantSingleQuotes] = { range, string in
            guard let swiftRange = Range(range, in: string) else { fatalError("Failed to parse range") }

            var constant = String(string[swiftRange])
            constant.removeFirst()
            constant.removeLast()

            return .stringConstant(constant: constant)
        }

        matchers[numberConstant] = { range, string in
            guard let swiftRange = Range(range, in: string) else { fatalError("Failed to parse range") }
            guard let double = Double(String(string[swiftRange])) else {
                fatalError("Failed to parse number constant")
            }
            return .numberConstant(constant: double)
        }

        return matchers
    }
}
