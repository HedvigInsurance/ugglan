//
//  UIViewController+PreferredContentSizeSignal.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-09.
//

import Flow
import Foundation
import UIKit

extension UIViewController {
    var preferredContentSizeSignal: ReadSignal<CGSize> {
        return signal(for: \.preferredContentSize)
    }
}
