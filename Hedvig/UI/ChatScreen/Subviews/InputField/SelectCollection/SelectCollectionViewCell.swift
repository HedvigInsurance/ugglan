//
//  SelectCollectionViewCell.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-16.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura
import UIKit

private let cellPadding: CGFloat = 5

class SelectCollectionViewCell: UICollectionViewCell, View {
    var selectButton = SelectButton()
    var isHeightCalculated = false
    var choice: MessageBodySingleSelectFragment.Choice?

    var onSelect: ((_ choice: MessageBodySingleSelectFragment.Choice?) -> Void)?

    override func layoutSubviews() {
        selectButton.pin.sizeToFit()
        selectButton.pin.top(10)
    }

    func setup() {
        addSubview(selectButton)
        selectButton.onSelect = {
            self.onSelect?(self.choice)
        }
    }

    func style() {}

    func update() {
        selectButton.text = choice?
            .fragments
            .messageBodyChoicesSelectionFragment?
            .fragments
            .messageBodyChoicesCoreFragment.text
        selectButton.update()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }

    override func sizeThatFits(_: CGSize) -> CGSize {
        return CGSize(width: selectButton.frame.width, height: 30)
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        if !isHeightCalculated {
            setNeedsLayout()
            layoutIfNeeded()
            var newFrame = layoutAttributes.frame
            newFrame.size.width = selectButton.frame.width + cellPadding
            layoutAttributes.frame = newFrame
            isHeightCalculated = true
        }
        return layoutAttributes
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
