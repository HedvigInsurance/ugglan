//
//  CircleLabelWithSubLabel.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import UIKit

struct CircleLabelWithSubLabel {
    let labelText: DynamicString
    let subLabelText: DynamicString
    let appearance: Appearance

    enum Appearance {
        case purple, turquoise, white, secondaryBackground
    }

    init(labelText: DynamicString, subLabelText: DynamicString, appearance: Appearance) {
        self.labelText = labelText
        self.subLabelText = subLabelText
        self.appearance = appearance
    }
}

extension CircleLabelWithSubLabel: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let circleView = UIView()
        let bag = DisposeBag()

        let labelsContainer = CenterAllStackView()
        labelsContainer.axis = .vertical

        let titleLabel = UILabel()
        titleLabel.font = HedvigFonts.favoritStdBook?.withSize(48)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        bag += titleLabel.setDynamicText(labelText)

        let subLabel = UILabel()
        subLabel.font = HedvigFonts.favoritStdBook?.withSize(18)
        subLabel.lineBreakMode = .byWordWrapping
        subLabel.numberOfLines = 0
        subLabel.textAlignment = .center
        subLabel.adjustsFontSizeToFitWidth = true
        bag += subLabel.setDynamicText(subLabelText)

        bag += circleView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.2,
                offset: CGSize(width: 10, height: 10),
                radius: 16,
                color: .primaryShadowColor,
                path: nil
            )
        }

        switch appearance {
        case .turquoise:
            circleView.backgroundColor = .turquoise
            titleLabel.textColor = .blackPurple
            subLabel.textColor = .blackPurple
        case .purple:
            circleView.backgroundColor = .purple
            titleLabel.textColor = .white
            subLabel.textColor = .white
        case .white:
            circleView.backgroundColor = .white
            titleLabel.textColor = .offBlack
            subLabel.textColor = .offBlack
        case .secondaryBackground:
            circleView.backgroundColor = .secondaryBackground
            titleLabel.textColor = .white
            subLabel.textColor = .offWhite
        }

        labelsContainer.addArrangedSubview(titleLabel)
        labelsContainer.addArrangedSubview(subLabel)

        circleView.addSubview(labelsContainer)

        labelsContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bag += circleView.didLayoutSignal.onValue { _ in
            circleView.layer.cornerRadius = circleView.frame.height * 0.5
        }

        circleView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalTo(circleView.snp.height)
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        return (circleView, bag)
    }
}
