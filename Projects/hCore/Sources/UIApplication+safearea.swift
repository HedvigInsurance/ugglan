import Foundation
import UIKit

extension UIApplication {
    public var safeArea: UIEdgeInsets? {
        (connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene)?
            .windows.first?
            .rootViewController?
            .view.safeAreaInsets
    }
}
