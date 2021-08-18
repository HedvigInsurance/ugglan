import Foundation
import UIKit

public struct TransitionStyle {
    var duration: TimeInterval
    var options: UIView.AnimationOptions

    public init(
        duration: TimeInterval,
        options: UIView.AnimationOptions
    ) {
        self.duration = duration
        self.options = options
    }
}

extension TransitionStyle {
    public static func crossDissolve(duration: TimeInterval) -> TransitionStyle {
        TransitionStyle(duration: duration, options: [.transitionCrossDissolve, .allowUserInteraction])
    }
}
