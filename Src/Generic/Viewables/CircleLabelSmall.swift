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

struct CircleLabelSmall {
    let labelText: DynamicString
    let color: Color

    enum Color {
        case green
    }

    init(labelText: DynamicString, color: Color) {
        self.labelText = labelText
        self.color = color
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
        bag += titleLabel.setDynamicText(labelText)

        circleView.layer.shadowOpacity = 0.2
        circleView.layer.shadowOffset = CGSize(width: 10, height: 10)
        circleView.layer.shadowRadius = 16
        circleView.layer.shadowColor = UIColor.darkGray.cgColor

        switch color {
        case .green:
            circleView.backgroundColor = UIColor.darkGreen
            titleLabel.textColor = UIColor.white
        }

        labelsContainer.addArrangedSubview(titleLabel)

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
