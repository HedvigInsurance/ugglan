//
//  CenterAllStackView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-18.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

class CenterAllStackView: UIStackView {
    let horizontalStackView = UIStackView()
    let internalStackView = UIStackView()

    override var alignment: UIStackView.Alignment {
        get {
            return internalStackView.alignment
        }
        set(newValue) {
            internalStackView.alignment = newValue
        }
    }

    override var axis: NSLayoutConstraint.Axis {
        get {
            return internalStackView.axis
        }
        set(newValue) {
            internalStackView.axis = newValue
        }
    }

    override var spacing: CGFloat {
        get {
            return internalStackView.spacing
        }
        set(newValue) {
            internalStackView.spacing = newValue
        }
    }

    override var distribution: UIStackView.Distribution {
        get {
            return internalStackView.distribution
        }
        set(newValue) {
            internalStackView.distribution = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.alignment = .center
        super.axis = .vertical

        horizontalStackView.alignment = .center
        horizontalStackView.axis = .horizontal

        addArrangedSubview(horizontalStackView)

        horizontalStackView.addArrangedSubview(internalStackView)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func addArrangedSubview(_ view: UIView) {
        if view == horizontalStackView {
            super.addArrangedSubview(view)
            return
        }

        internalStackView.addArrangedSubview(view)
    }
}
