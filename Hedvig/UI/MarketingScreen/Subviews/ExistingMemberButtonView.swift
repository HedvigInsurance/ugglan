//
//  ExistingMemberButtonView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-22.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

class ExistingMemberButtonView: UIButton, View {
    var onButtonPress: Interaction?
    let label = UILabel()

    func setup() {
        addSubview(label)
        label.text = "Logga in"
        addTarget(self, action: #selector(onTapRelease), for: .touchUpInside)
        addTarget(self, action: #selector(onTap), for: .touchDown)
        backgroundColor = HedvigColors.black.withAlphaComponent(0.5)

        label.snp.makeConstraints { make in
            make.center.equalTo(self.snp.center)
        }
    }

    func style() {
        layer.cornerRadius = 20
        label.textColor = HedvigColors.white
        label.font = HedvigFonts.circularStdBook?.withSize(14)
        label.textAlignment = .center
    }

    func update() {}

    @objc func onTap() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = HedvigColors.black.withAlphaComponent(0.7)
        }
    }

    @objc func onTapRelease() {
        onButtonPress?()

        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
            self.backgroundColor = HedvigColors.black.withAlphaComponent(0.1)
        }, completion: nil)
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
