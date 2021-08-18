import Foundation
import UIKit

extension Notification {
    public struct KeyboardInfo {
        public let height: CGFloat
        public let animationDuration: TimeInterval
        public let animationCurve: UIView.AnimationOptions
        public let beginFrame: CGRect
        public let endFrame: CGRect
    }

    // parses keyboard info from userInfo if available
    public var keyboardInfo: KeyboardInfo? {
        if let userInfo = userInfo,
            let keyboardFrame: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let duration =
                (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
                ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw =
                animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? CGRect.zero
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero

            return KeyboardInfo(
                height: keyboardHeight,
                animationDuration: duration,
                animationCurve: animationCurve,
                beginFrame: beginFrame,
                endFrame: endFrame
            )
        }

        return nil
    }
}
