import Foundation

public struct RouterDestionationOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension RouterDestionationOptions {
    public static let hidesBackButton = RouterDestionationOptions()
}
