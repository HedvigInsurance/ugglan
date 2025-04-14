import Apollo
import Foundation

extension GraphQLNullable {
    public init(optionalValue value: Wrapped?) {
        if let value {
            self = .some(value)
        } else {
            self = .none
        }
    }
}
