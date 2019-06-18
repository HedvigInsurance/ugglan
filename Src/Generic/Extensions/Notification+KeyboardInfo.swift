//
//  Notification+KeyboardInfo.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-13.
//

import Foundation
import UIKit

extension Notification {
    struct KeyboardInfo {
        let height: CGFloat
        let animationDuration: TimeInterval
        let animationCurve: UIView.AnimationOptions
    }

    // parses keyboard info from userInfo if available
    // containerView: UIView - the view to calculate safe area from
    var keyboardInfo: KeyboardInfo? {
        if let userInfo = userInfo, let keyboardFrame: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
            
            let safeAreaBottom: CGFloat
            
            if #available(iOS 11, *) {
                safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            } else {
                safeAreaBottom = 0
            }

            return KeyboardInfo(height: keyboardHeight - safeAreaBottom, animationDuration: duration, animationCurve: animationCurve)
        }

        return nil
    }
}
