import Foundation
import SwiftUI

extension UIApplication {
    public static func dismissKeyboard() {
        DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?
                .windows
                .filter(\.isKeyWindow).first
            keyWindow?.endEditing(true)
        }
    }
}
