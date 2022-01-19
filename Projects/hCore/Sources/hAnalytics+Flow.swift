import Flow
import Foundation
import UIKit
import hAnalytics

extension UIViewController {
    /// sends a tracking event when didMoveToWindow is called
    public func trackDidMoveToWindow(_ track: hAnalytics.AnalyticsClosure) -> Disposable {
        self.view.didMoveToWindowSignal.onValue { _ in
            track.send()
        }
    }
}
