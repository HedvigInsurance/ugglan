import Flow
import Foundation
import UIKit

public extension UIControl {
    static var trackingHandler: (_ button: UIControl) -> Void = { _ in }

    /// Triggers on touchUpInside and uses accessibilityLabel to trigger an analytics event
    var trackedTouchUpInsideSignal: Signal<Void> {
        signal(for: .touchUpInside).atValue {
            Self.trackingHandler(self)
        }
    }
}
