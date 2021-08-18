import Foundation
import UIKit

public struct AnimationStyle {
    public var options: UIView.AnimationOptions
    public var duration: TimeInterval
    public var delay: TimeInterval

    public init(
        options: UIView.AnimationOptions,
        duration: TimeInterval,
        delay: TimeInterval
    ) {
        self.options = options
        self.duration = duration
        self.delay = delay
    }
}

extension AnimationStyle {
    public static func easeOut(duration: TimeInterval, delay: TimeInterval = 0) -> AnimationStyle {
        AnimationStyle(options: .curveEaseOut, duration: duration, delay: delay)
    }

    public static func easeIn(duration: TimeInterval, delay: TimeInterval = 0) -> AnimationStyle {
        AnimationStyle(options: .curveEaseIn, duration: duration, delay: delay)
    }

    public static func linear(duration: TimeInterval, delay: TimeInterval = 0) -> AnimationStyle {
        AnimationStyle(options: .curveLinear, duration: duration, delay: delay)
    }
}
