//
//  MarketingView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-17.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Katana
import PinLayout
import Tempura

class MarketingView: UIView, ViewControllerModellableView {
    let openChatButton = OpenChatButton()
    var didTapOpenChat: Interaction?

    func setup() {
        openChatButton.onButtonPress = {
            self.didTapOpenChat?()
        }

        addSubview(openChatButton)
    }

    func style() {
        backgroundColor = UIColor.red
    }

    func update(oldModel _: MarketingViewModel?) {}

    override func layoutSubviews() {
        openChatButton.pin.center()
        openChatButton.pin.width(100%)
        openChatButton.pin.height(100%)
    }
}

struct MarketingViewModel: ViewModelWithState, Equatable {
    init?(state _: AppState) {}
}
