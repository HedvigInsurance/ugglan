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

    /// iOS 26 keeps the window's keyboard first-responder context pointing at the last focused
    /// text view (and, via its trait collection, the hosting SwiftUI graph) after a sheet is
    /// dismissed. Briefly focusing a hidden throwaway field rebinds that context so the retained
    /// views can release. Call from a screen's teardown when it hosts a text input inside a sheet.
    public static func releaseKeyboardRetainedViews() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.getWindow() else { return }
            let dummyTextField = UITextField()
            dummyTextField.isHidden = true
            dummyTextField.inputView = UIView()
            window.addSubview(dummyTextField)
            dummyTextField.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dummyTextField.removeFromSuperview()
            }
        }
    }
}
