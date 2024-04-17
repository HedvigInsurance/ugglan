import Foundation

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
