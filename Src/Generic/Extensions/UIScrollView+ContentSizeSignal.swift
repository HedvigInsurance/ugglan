//
//  UIScrollView+ContentSizeSignal.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-04.
//

import Flow
import Foundation
import UIKit

extension UIScrollView {
    var contentSizeSignal: ReadSignal<CGSize> {
        signal(for: \.contentSize)
    }
}
