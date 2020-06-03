//
//  PersonsInHouseholdBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Flow
import Foundation
import hCore
import hCoreUI
import UIKit

struct PersonsInHouseholdBubble {
    let personsInHousehold: Int
}

extension PersonsInHouseholdBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()

        let content = CenterAllStackView()
        content.axis = .vertical

        let titleLabel = MultilineLabel(
            value: L10n.offerBubblesInsuredTitle,
            style: .offerBubbleTitle
        )
        bag += content.addArranged(titleLabel)

        let subtitleLabel = MultilineLabel(
            value: L10n.offerBubblesInsuredSubtitle(String(personsInHousehold)),
            style: .offerBubbleSubtitle
        )
        bag += content.addArranged(subtitleLabel)

        let offerBubble = OfferBubble(
            content: content,
            width: 110,
            height: 110,
            backgroundColor: .purple
        )

        return (offerBubble, bag)
    }
}
