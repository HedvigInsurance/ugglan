//
//  StartDateBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Flow
import Foundation
import UIKit
import Core

struct StartDateBubble {
    let insuredAtOtherCompany: Bool
}

extension StartDateBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()

        let content = CenterAllStackView()
        content.axis = .vertical

        let titleLabel = MultilineLabel(
            value: L10n.offerBubblesStartDateTitle,
            style: .offerBubbleTitle
        )
        bag += content.addArranged(titleLabel)

        let subtitleLabel = MultilineLabel(
            value: insuredAtOtherCompany ? L10n.offerBubblesStartDateSubtitleSwitcher : L10n.offerBubblesStartDateSubtitleNew,
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
