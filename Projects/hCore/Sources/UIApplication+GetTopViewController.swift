import Foundation
import UIKit

extension UIApplication {
    public func getTopViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?
            .windows
            .filter({ $0.isKeyWindow })
            .first?
            .rootViewController?
            .getTopPresendedViewController()
    }

    public func getTopViewControllerNavigation() -> UINavigationController? {
        let topVC = UIApplication.shared.connectedScenes
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?
            .windows
            .filter({ $0.isKeyWindow })
            .first?
            .rootViewController?
            .getTopPresendedViewController()

        if let topVC = topVC as? UITabBarController {
            if let topVC = topVC.selectedViewController as? UINavigationController {
                return topVC
            }
        } else if let topVC = topVC as? UINavigationController {
            return topVC
        }
        return nil
    }
}

extension UIViewController {
    func getTopPresendedViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.getTopPresendedViewController()
        }
        return self
    }
}
