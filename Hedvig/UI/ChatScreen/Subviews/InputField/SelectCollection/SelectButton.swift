//
//  SelectButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-16.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

class SelectButton: UIButton, View {
    private var labelView = UILabel()
    var text: String! {
        didSet {
            labelView.text = text
        }
    }

    var onSelect: (() -> Void)?

    func setup() {
        addSubview(labelView)
        addTarget(self, action: #selector(onTapCancel), for: .touchCancel)
        addTarget(self, action: #selector(onTap), for: .touchDown)
        addTarget(self, action: #selector(onTapRelease), for: .touchUpInside)
    }

    @objc func onTap() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = HedvigColors.purple
            self.labelView.textColor = HedvigColors.white
        }
    }

    @objc func onTapRelease() {
        onSelect?()
    }

    @objc func onTapCancel() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = UIColor.clear
            self.labelView.textColor = HedvigColors.purple
        }
    }

    func style() {
        layer.borderWidth = 1
        layer.borderColor = HedvigColors.purple.cgColor

        backgroundColor = UIColor.clear

        labelView.font = HedvigFonts.circularStdBook?.withSize(14)
        labelView.textColor = HedvigColors.purple
    }

    func update() {
        style()
        labelView.layoutIfNeeded()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        labelView.pin.sizeToFit().size(labelView.intrinsicContentSize)
        pin.wrapContent(padding: PEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        layer.cornerRadius = frame.height / 2
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
