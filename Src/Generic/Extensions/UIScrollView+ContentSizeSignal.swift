//
//  UIScrollView+ContentSizeSignal.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-04.
//

import Foundation
import UIKit
import Flow

extension UIScrollView {
    var contentSizeSignal: ReadSignal<CGSize> {
        signal(for: \.contentSize)
    }
}
