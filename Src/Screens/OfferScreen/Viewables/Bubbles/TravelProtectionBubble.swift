//
//  TravelProtectionBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Flow
import Foundation
import UIKit
import ComponentKit

struct TravelProtectionBubble {}

extension TravelProtectionBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()

        let content = CenterAllStackView()
        content.axis = .vertical
        content.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 0)
        content.isLayoutMarginsRelativeArrangement = true

        let titleLabel = MultilineLabel(
            value: String(key: .OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE),
            style: .offerBubbleTitle
        )
        bag += content.addArranged(titleLabel)

        let offerBubble = OfferBubble(
            content: content,
            width: 135,
            height: 135,
            backgroundColor: .hedvig(.purple)
        )

        return (offerBubble, bag)
    }
}
