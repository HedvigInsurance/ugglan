//
//  UIView+RelativeFrame.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-14.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func frameRelativeTo(view: UIView) -> CGRect {
        let viewRelativeFrame = view.convert(view.bounds, to: nil)
        let selfRelativeFrame = convert(bounds, to: nil)

        return CGRect(
            x: viewRelativeFrame.origin.x - selfRelativeFrame.origin.x,
            y: viewRelativeFrame.origin.y - selfRelativeFrame.origin.y,
            width: viewRelativeFrame.width - selfRelativeFrame.width,
            height: viewRelativeFrame.height - selfRelativeFrame.height
        )
    }
}
