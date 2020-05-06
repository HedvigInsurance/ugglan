//
//  OwnedAddonBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-08.
//

import Flow
import Foundation
import UIKit

struct OwnedAddonBubble {}

extension OwnedAddonBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (OfferBubble, Disposable) {
        let bag = DisposeBag()

        let content = CenterAllStackView()
        content.axis = .vertical

        let titleLabel = MultilineLabel(
            value: L10n.offerBubblesOwnedAddonTitle,
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
