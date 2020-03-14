//
//  KeyGearAddButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Flow
import Form
import Foundation
import UIKit

struct KeyGearAddButton {}

extension KeyGearAddButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Signal<Void>) {
        let view = UIControl()
        view.accessibilityLabel = String(key: .KEY_GEAR_ADD_BUTTON)

        let bag = DisposeBag()

        view.layer.cornerRadius = 8
        view.backgroundColor = .secondaryTintColor

        let contentContainer = UIStackView()
        contentContainer.spacing = 10
        contentContainer.isUserInteractionEnabled = false
        contentContainer.axis = .vertical
        contentContainer.alignment = .center
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        let icon = Icon(icon: Asset.addButton, iconWidth: 32)
        contentContainer.addArrangedSubview(icon)

        let label = MultilineLabel(value: String(key: .KEY_GEAR_ADD_BUTTON), style: TextStyle.body.colored(.primaryTintColor))
        bag += contentContainer.addArranged(label)

        let touchUpInsideSignal = view.trackedTouchUpInsideSignal

        bag += touchUpInsideSignal.feedback(type: .impactLight)

        bag += view.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
            view.backgroundColor = UIColor.secondaryTintColor.darkened(amount: 0.05)
            view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }

        bag += view.delayedTouchCancel(delay: 0.1).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
            view.backgroundColor = .secondaryTintColor
            view.transform = CGAffineTransform.identity
        }

        return (view, touchUpInsideSignal.hold(bag))
    }
}
