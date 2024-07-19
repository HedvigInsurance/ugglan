import Foundation

public struct RouterDestionationOptions: OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

extension RouterDestionationOptions {
    public static let hidesBackButton = RouterDestionationOptions(rawValue: 1 << 0)
    public static let hidesBottomBarWhenPushed = RouterDestionationOptions(rawValue: 1 << 1)
}
