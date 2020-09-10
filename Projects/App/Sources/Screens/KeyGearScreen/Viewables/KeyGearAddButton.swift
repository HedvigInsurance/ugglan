//
//  KeyGearAddButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct KeyGearAddButton {}

extension KeyGearAddButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Signal<Void>) {
        let view = UIControl()
        view.accessibilityLabel = L10n.keyGearAddButton

        let bag = DisposeBag()

        view.layer.cornerRadius = 8
        view.backgroundColor = .brand(.link)

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

        let icon = Icon(icon: Asset.addButton.image, iconWidth: 32)
        contentContainer.addArrangedSubview(icon)

        let label = MultilineLabel(value: L10n.keyGearAddButton, style: TextStyle.brand(.body(color: .primary)))
        bag += contentContainer.addArranged(label)

        let touchUpInsideSignal = view.trackedTouchUpInsideSignal

        bag += touchUpInsideSignal.feedback(type: .impactLight)

        bag += view.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
            view.backgroundColor = UIColor.brand(.link).darkened(amount: 0.05)
            view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }

        bag += view.delayedTouchCancel(delay: 0.1).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
            view.backgroundColor = .brand(.link)
            view.transform = CGAffineTransform.identity
        }

        return (view, touchUpInsideSignal.hold(bag))
    }
}
