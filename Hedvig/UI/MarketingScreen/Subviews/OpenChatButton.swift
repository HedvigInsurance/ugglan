//
//  OpenChatButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-17.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

class OpenChatButton: UIButton, View {
    var onButtonPress: Interaction?

    func setup() {
        addTarget(self, action: #selector(onTapRelease), for: .touchUpInside)
    }

    func style() {
        backgroundColor = HedvigColors.purple
    }

    func update() {}

    @objc func onTapRelease() {
        onButtonPress?()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        pin.width(50)
        pin.height(50)
    }
}
