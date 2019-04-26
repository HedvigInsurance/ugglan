//
//  UIScrollView+ContentOffsetSignal.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-26.
//

import Foundation
import Flow
import UIKit

extension UIScrollView {
    var contentOffsetSignal: Signal<CGPoint> {
        return Signal { callback in
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
