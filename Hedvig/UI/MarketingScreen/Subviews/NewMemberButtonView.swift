//
//  NewMemberButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-22.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

class NewMemberButtonView: UIButton, View {
    var onButtonPress: Interaction?
    let label = UILabel()

    func setup() {
        addSubview(label)
        label.text = "Ny här?"
        addTarget(self, action: #selector(onTapRelease), for: .touchUpInside)
        addTarget(self, action: #selector(onTap), for: .touchDown)

        label.snp.makeConstraints { make in
            make.center.equalTo(self.snp.center)
        }
    }

    func style() {
        backgroundColor = HedvigColors.white
        layer.cornerRadius = 20
        label.font = HedvigFonts.circularStdBook?.withSize(14)
        label.textAlignment = .center
    }

    func update() {}

    @objc func onTap() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = HedvigColors.white.darkened(amount: 0.05)
        }
    }

    @objc func onTapRelease() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
            self.backgroundColor = HedvigColors.white
        }, completion: nil)

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
}
