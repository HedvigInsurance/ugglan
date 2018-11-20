//
//  SendButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura

private struct Styles {
    static func backgroundColor(activated: Bool) -> UIColor {
        if activated {
            return HedvigColors.purple
        } else {
            return HedvigColors.darkGray
        }
    }

    static func highlightedBackgroundColor(activated: Bool) -> UIColor {
        return backgroundColor(activated: activated).darkened(amount: 0.25)
    }
}

class SendButton: UIButton, View {
    let arrowUpIcon = Icon(frame: .zero, iconName: "ArrowUp", iconWidth: 10)
    var activated: Bool {
        didSet {
            update()
        }
    }

    var onSend: () -> Void

    init(frame: CGRect, onSend: @escaping () -> Void) {
        self.onSend = onSend
        activated = false
        super.init(frame: frame)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(arrowUpIcon)
        addTarget(self, action: #selector(onTap), for: .touchDown)
        addTarget(self, action: #selector(onTapRelease), for: .touchUpInside)
    }

    func style() {
        backgroundColor = Styles.backgroundColor(activated: activated)
        layer.cornerRadius = 15
    }

    func update() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = Styles.backgroundColor(activated: self.activated)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(30)
        pin.height(30)
        arrowUpIcon.pin.center()
    }

    @objc func onTap() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = Styles.highlightedBackgroundColor(activated: self.activated)
        }
    }

    @objc func onTapRelease() {
        if activated {
            onSend()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }

        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = Styles.backgroundColor(activated: self.activated)
        }
    }
}
