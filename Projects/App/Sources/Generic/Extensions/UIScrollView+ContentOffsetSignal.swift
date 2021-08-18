import Flow
import Foundation
import UIKit

extension UIScrollView {
  var contentOffsetSignal: Signal<CGPoint> {
    Signal { callback in
      var observer: NSKeyValueObservation? = self.observe(\.contentOffset) { _, _ in
        callback(self.contentOffset)
      }

      return Disposer {
        observer?.invalidate()
        observer = nil
      }
    }
  }
}
