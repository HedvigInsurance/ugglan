import Foundation
import UIKit

extension UIApplication {
    public func getTopViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?
            .windows
            .filter({ $0.isKeyWindow })
            .first?
            .rootViewController?
            .getTopPresendedViewController()
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
