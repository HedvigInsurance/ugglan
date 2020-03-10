//
//  UIView+LayoutSuperviews.swift
//  project
//
//  Created by Sam Pettersson on 2019-05-07.
//

import Foundation
import UIKit

public extension UIView {
    // recursively goes through all superviews and calls layoutIfNeeded()
    func layoutSuperviewsIfNeeded() {
        superview?.layoutIfNeeded()
        superview?.layoutSuperviewsIfNeeded()
    }
}
