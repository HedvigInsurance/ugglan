import Foundation

extension GraphQLNullable {
    public init(optionalValue value: Wrapped?) {
        if let value {
            self = .some(value)
        } else {
            self = .none  // <- change this to .null if your server requires
        }
    }
}
