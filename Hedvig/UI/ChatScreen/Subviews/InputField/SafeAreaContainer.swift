//
//  SafeAreaContainer.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-16.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

class SafeAreaContainer: UIVisualEffectView, View {
    var borderView = UIView()
    var safeAreaContainer = UIView()
    var heightConstraint: NSLayoutConstraint?

    func setup() {
        effect = UIBlurEffect(style: .extraLight)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        safeAreaContainer.translatesAutoresizingMaskIntoConstraints = false

        safeAreaContainer.addSubview(borderView)
        contentView.addSubview(safeAreaContainer)

        safeAreaContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true

        safeAreaContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        safeAreaContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true

        safeAreaContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true

        heightConstraint = safeAreaContainer.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint?.isActive = true
    }

    func style() {
        backgroundColor = HedvigColors.white.withAlphaComponent(0.7)
        borderView.backgroundColor = HedvigColors.grayBorder
    }

    func update() {}

    func heightDidChange(height: CGFloat) {
        heightConstraint?.constant = height
    }

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        borderView.pin.width(100%)
        borderView.pin.height(1)
        borderView.pin.top(0)
    }
}
