//
//  CharityHeader.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-21.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

struct CharityHeader {}

extension CharityHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 15

        stackView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        stackView.isLayoutMarginsRelativeArrangement = true

        let icon = Icon(frame: .zero, icon: Asset.charity, iconWidth: 40)
        stackView.addArrangedSubview(icon)

        let multilineLabel = MultilineLabel(
            styledText: StyledText(
                text: String.translation(.CHARITY_SCREEN_HEADER_MESSAGE),
                style: .centeredBody
            )
        )

        bag += stackView.addArangedSubview(multilineLabel)

        let sectionHeaderLabel = UILabel(value: "Välgörenhetsorganisationer", style: .sectionHeader)
        stackView.addArrangedSubview(sectionHeaderLabel)

        return (stackView, bag)
    }
}
