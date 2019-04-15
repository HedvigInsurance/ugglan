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
            top: 30,
            left: 20,
            bottom: 0,
            right: 20
        )
        stackView.isLayoutMarginsRelativeArrangement = true

        let icon = Icon(frame: .zero, icon: Asset.charityWhiteCircle, iconWidth: 40)
        stackView.addArrangedSubview(icon)

        let multilineLabel = MultilineLabel(
            styledText: StyledText(
                text: String(key: .CHARITY_SCREEN_HEADER_MESSAGE),
                style: .centeredBodyOffBlack
            )
        )

        bag += stackView.addArranged(multilineLabel)

        return (stackView, bag)
    }
}
