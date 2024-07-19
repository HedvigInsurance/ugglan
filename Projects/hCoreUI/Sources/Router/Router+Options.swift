import Foundation

public struct RouterOptions: OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

extension RouterOptions {
    public static let navigationBarHidden = RouterOptions(rawValue: 1 << 0)
    static let largeNavigationBar = RouterOptions(rawValue: 1 << 1)
    static let navigationBarWithProgress = RouterOptions(rawValue: 1 << 2)

    public static func navigationType(type: NavigationBarType) -> RouterOptions {
        switch type {
        case .large:
            return largeNavigationBar
        case .withProgress:
            return navigationBarWithProgress
        }
    }
}

public enum NavigationBarType {
    case large
    case withProgress
}
