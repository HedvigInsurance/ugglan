//
//  UIScrollView+ContentSizeSignal.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIScrollView {
    public var contentSizeSignal: ReadSignal<CGSize> {
        signal(for: \.contentSize)
    }
}
