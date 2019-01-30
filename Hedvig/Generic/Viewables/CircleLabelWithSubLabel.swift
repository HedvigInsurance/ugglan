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
import UIKit

struct CircleLabelWithSubLabel {
    let labelText: DynamicString
    let subLabelText: DynamicString
    let color: String

    init(labelText: DynamicString, subLabelText: DynamicString, color: String) {
        self.labelText = labelText
        self.subLabelText = subLabelText
        self.color = color
    }
}

extension CircleLabelWithSubLabel: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let circleView = UIView()
        let bag = DisposeBag()

        let labelsContainer = CenterAllStackView()
        labelsContainer.axis = .vertical

        let titleLabel = UILabel()
        titleLabel.font = HedvigFonts.circularStdBold?.withSize(48)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        bag += titleLabel.setDynamicText(labelText)

        let subLabel = UILabel()
        subLabel.font = HedvigFonts.circularStdBook?.withSize(18)
        subLabel.lineBreakMode = .byWordWrapping
        subLabel.numberOfLines = 0
        subLabel.textAlignment = .center
        subLabel.adjustsFontSizeToFitWidth = true
        bag += subLabel.setDynamicText(subLabelText)

        circleView.layer.shadowOpacity = 0.2
        circleView.layer.shadowOffset = CGSize(width: 10, height: 10)
        circleView.layer.shadowRadius = 16
        circleView.layer.shadowColor = UIColor.darkGray.cgColor

        switch color {
        case "turquoise":
            circleView.backgroundColor = UIColor.turquoise
            titleLabel.textColor = UIColor.blackPurple
            subLabel.textColor = UIColor.blackPurple
        default:
            circleView.backgroundColor = UIColor.gray
            titleLabel.textColor = UIColor.white
            subLabel.textColor = UIColor.white
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
