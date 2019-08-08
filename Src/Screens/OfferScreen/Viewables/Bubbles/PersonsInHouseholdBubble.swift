//
//  PersonsInHouseholdBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Foundation
import Flow
import UIKit

struct PersonsInHouseholdBubble {}

extension PersonsInHouseholdBubble: Viewable {
    func materialize(events: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()
        
        let content = CenterAllStackView()
        content.axis = .vertical
        
        let titleLabel = MultilineLabel(
            value: String(key: .OFFER_BUBBLES_INSURED_TITLE),
            style: .offerBubbleTitle
        )
        bag += content.addArranged(titleLabel)
        
        let subtitleLabel = MultilineLabel(
            value: String(key: .OFFER_BUBBLES_INSURED_SUBTITLE(personsInHousehold: "2")),
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
