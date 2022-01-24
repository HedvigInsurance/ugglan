import Flow
import Foundation
import UIKit
import hAnalytics

extension UIViewController {
    /// sends a tracking event when didMoveToWindow is called
    public func trackDidMoveToWindow(_ track: hAnalytics.AnalyticsClosure) -> Disposable {
        self.view.windowSignal.atOnce().filter(predicate: { $0 != nil })
            .onValue { _ in
                track.send()
            }
    }
}

extension UIView {
    /// sends a tracking event when didMoveToWindow is called
    public func trackDidMoveToWindow(_ track: hAnalytics.AnalyticsClosure) -> Disposable {
        self.windowSignal.atOnce().filter(predicate: { $0 != nil })
            .onValue { _ in
                track.send()
            }
    }
}
