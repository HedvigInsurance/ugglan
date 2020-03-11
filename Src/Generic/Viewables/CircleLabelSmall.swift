//
//  CircleLabelSmall.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct CircleLabelSmall {
    let labelText: DynamicString
    let textColor: UIColor
    let backgroundColor: UIColor

    init(labelText: DynamicString, textColor: UIColor, backgroundColor: UIColor) {
        self.labelText = labelText
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}

extension CircleLabelSmall: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let circleView = UIView()
        let bag = DisposeBag()

        let labelsContainer = CenterAllStackView()
        labelsContainer.axis = .vertical

        let titleLabel = UILabel()
        titleLabel.font = HedvigFonts.circularStdBook?.withSize(14)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = textColor
        bag += titleLabel.setDynamicText(labelText)

        bag += circleView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.2,
                offset: CGSize(width: 10, height: 10),
                radius: 16,
                color: UIColor.hedvig(.primaryShadowColor),
                path: nil
            )
        }

        circleView.backgroundColor = backgroundColor
        titleLabel.textColor = .hedvig(.primaryText)

        labelsContainer.addArrangedSubview(titleLabel)

        circleView.addSubview(labelsContainer)

        labelsContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bag += circleView.didLayoutSignal.onValue { _ in
            circleView.layer.cornerRadius = circleView.frame.height * 0.5
        }

        bag += circleView.didMoveToWindowSignal.take(first: 1).onValue({ _ in
            circleView.snp.makeConstraints { make in
                make.width.equalTo(circleView.snp.height)
                make.height.equalToSuperview()
                make.center.equalToSuperview()
            }
        })

        return (circleView, bag)
    }
}
