//
//  UIViewController+PreferredContentSizeSignal.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-09.
//

import Foundation
import Flow
import UIKit

extension UIViewController {
    var preferredContentSizeSignal: ReadSignal<CGSize> {
        return self.signal(for: \.preferredContentSize)
    }
}
