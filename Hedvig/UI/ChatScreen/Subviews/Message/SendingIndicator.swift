//
//  SendingIndicator.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-15.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import PinLayout
import Tempura

class SendingIndicator: UIView, View {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        label.text = "Skickar..."
        addSubview(label)
    }

    func style() {
        label.font = HedvigFonts.circularStdBook?.withSize(10)
    }

    func update() {}

    override func layoutSubviews() {
        label.pin.sizeToFit()
        label.pin.right(0)
        pin.width(100%)
        pin.wrapContent(padding: 5)
        pin.right(10)
    }
}
