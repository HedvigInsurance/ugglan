import Foundation

enum BinaryOperator: String, Equatable {
    case addition = "+"
    case subtraction = "-"
    case concatenation = "++"
}

enum Token: Equatable { case void
    case binaryOperator(operator: BinaryOperator)
    case storeKey(key: String)
    case stringConstant(constant: String)
    case numberConstant(constant: Double)
}
