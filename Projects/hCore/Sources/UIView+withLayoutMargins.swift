//
//  UIView+withLayoutMargins.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-06-17.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public func withLayoutMargins(_ layoutMargins: UIEdgeInsets) -> UIStackView {
        let stackView = UIStackView()
        stackView.edgeInsets = layoutMargins
        stackView.addArrangedSubview(self)
        return stackView
    }
}
