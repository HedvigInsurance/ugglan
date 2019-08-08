//
//  OwnedAddonBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Foundation
import Flow
import UIKit

struct OwnedAddonBubble {}

extension OwnedAddonBubble: Viewable {
    func materialize(events: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()
        
        let content = CenterAllStackView()
        content.axis = .vertical
        
        let titleLabel = MultilineLabel(
            value: String(key: .OFFER_BUBBLES_OWNED_ADDON_TITLE),
            style: .offerBubbleTitle
        )
        bag += content.addArranged(titleLabel)
        
        let offerBubble = OfferBubble(
            content: content,
            width: 135,
            height: 135,
            backgroundColor: .purple
        )
        
        return (offerBubble, bag)
    }
}
