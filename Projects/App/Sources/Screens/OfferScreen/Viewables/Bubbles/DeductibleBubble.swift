//
//  DeductibleBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Flow
import Foundation
import hCore
import hCoreUI
import UIKit

struct DeductibleBubble {}

extension DeductibleBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()

        let content = CenterAllStackView()
        content.axis = .vertical

        let titleLabel = MultilineLabel(
            value: L10n.offerBubblesDeductibleTitle,
            style: .offerBubbleTitle
        )
        bag += content.addArranged(titleLabel)

        let subtitleLabel = MultilineLabel(
            value: L10n.offerBubblesDeductibleSubtitle,
            style: .offerBubbleSubtitle
        )
        bag += content.addArranged(subtitleLabel)

        let offerBubble = OfferBubble(
            content: content,
            width: 90,
            height: 90,
            backgroundColor: .turquoise
        )

        return (offerBubble, bag)
    }
}
