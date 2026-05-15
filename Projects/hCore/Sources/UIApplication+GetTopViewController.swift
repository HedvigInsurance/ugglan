import Foundation
import SwiftUI

extension UIApplication {
    public func getTopViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter(\.isKeyWindow)
            .first?
            .rootViewController?
            .getTopPresendedViewController()
    }

    public func getTopViewControllerNavigation() -> UINavigationController? {
        let topVC = UIApplication.shared.connectedScenes
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter(\.isKeyWindow)
            .first?
            .rootViewController?
            .getTopPresendedViewController()

        if let topVC = topVC as? UITabBarController {
            if let topVC = topVC.selectedViewController as? UINavigationController {
                return topVC
            }
        } else if let topVC = topVC as? UINavigationController {
            return topVC
        } else if let topVC = topVC,
            let navigationChildren = topVC.children.first(where: { $0 as? UINavigationController != nil })
                as? UINavigationController
        {
            return navigationChildren
        }
        return nil
    }

    public func getWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter(\.isKeyWindow)
            .first
    }

    public func getRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter(\.isKeyWindow)
            .first?
            .rootViewController
    }
}

extension UIViewController {
    func getTopPresendedViewController() -> UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.getTopPresendedViewController()
        }
        return self
    }
}
