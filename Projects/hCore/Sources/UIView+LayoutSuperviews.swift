//
//  UIView+LayoutSuperviews.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    // recursively goes through all superviews and calls layoutIfNeeded()
    public func layoutSuperviewsIfNeeded() {
        superview?.layoutIfNeeded()
        superview?.layoutSuperviewsIfNeeded()
    }
}
