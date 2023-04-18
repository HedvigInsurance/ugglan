import Foundation
import UIKit

extension UIApplication {
    public static func dismissKeyboard() {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?
            .windows
            .filter({ $0.isKeyWindow }).first
        keyWindow?.endEditing(true)
    }
}
