import Flow
import Foundation
import UIKit

extension Signal where Kind == Plain, Value == () {
    // a delay operator that respects slow animations, useful when building interactive animations
    public static func animatedDelay(after delay: TimeInterval) -> Signal<Void> {
        Signal { callback in let dummyView = UIView()
            dummyView.alpha = 0
            UIApplication.shared.windows.first?.rootView.addSubview(dummyView)

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
