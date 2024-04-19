import Foundation

public struct RouterOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension RouterOptions {
    public static let navigationBarHidden = RouterOptions()
    static let largeNavigationBar = RouterOptions()
    static let navigationBarWithProgress = RouterOptions()

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
