//
//  UIView+ApplyBorderColor.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIView {
    public func applyBorderColor(_ dynamic: @escaping (_ trait: UITraitCollection) -> UIColor) -> Disposable {
        traitCollectionSignal.atOnce().with(weak: self).onValue { trait, `self` in
            let color = dynamic(trait)
            self.layer.borderColor = color.cgColor
        }
    }
}
