//
//  StartDateBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Flow
import Foundation
import UIKit

struct StartDateBubble {
    let insuredAtOtherCompany: Bool
}

extension StartDateBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()

        let content = CenterAllStackView()
        content.axis = .vertical

        let titleLabel = MultilineLabel(
            value: String(key: .OFFER_BUBBLES_START_DATE_TITLE),
            style: .offerBubbleTitle
        )
        bag += content.addArranged(titleLabel)

        let subtitleLabel = MultilineLabel(
            value: String(key: insuredAtOtherCompany ?
                .OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER :
                .OFFER_BUBBLES_START_DATE_SUBTITLE_NEW),
            style: .offerBubbleSubtitle
        )
        bag += content.addArranged(subtitleLabel)

        let offerBubble = OfferBubble(
            content: content,
            width: 130,
            height: 130,
            backgroundColor: .turquoise
        )

        return (offerBubble, bag)
    }
}
