import Flow
import Foundation
import SwiftUI

extension Signal where Kind == Plain, Value == () {
    // a delay operator that respects slow animations, useful when building interactive animations
    public static func animatedDelay(after delay: TimeInterval) -> Signal<Void> {
        Signal { callback in let dummyView = UIView()
            dummyView.alpha = 0
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .first?
                .windows
                .filter({ $0.isKeyWindow }).first
            keyWindow?.rootView.addSubview(dummyView)

            let animator = UIViewPropertyAnimator(duration: delay, curve: .linear) { dummyView.alpha = 1 }

            animator.addCompletion { position in
                if position == .end {
                    dummyView.removeFromSuperview()
                    callback(())
                }
            }

            animator.startAnimation(afterDelay: 0)

            return Disposer { animator.stopAnimation(true) }
        }
        .take(first: 1).plain()
    }

    public func animatedDelay(after delay: TimeInterval) -> Signal<Void> {
        flatMapLatest { Self.animatedDelay(after: delay) }
    }
}
