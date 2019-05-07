//
//  UIView+LayoutSuperviews.swift
//  project
//
//  Created by Sam Pettersson on 2019-05-07.
//

import Foundation
import UIKit

extension UIView {
    // recursively goes through all superviews and calls layoutIfNeeded()
    func layoutSuperviewsIfNeeded() {
        self.superview?.layoutIfNeeded()
        self.superview?.layoutSuperviewsIfNeeded()
    }
}
