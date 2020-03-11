//
//  AttachFileButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-26.
//

import Flow
import Foundation
import UIKit
import ComponentKit

struct AttachFileButton {
    let isOpenSignal: ReadSignal<Bool>
}

extension AttachFileButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Signal<Void>) {
        let bag = DisposeBag()
        let control = UIControl()
        control.backgroundColor = .hedvig(.primaryTintColor)
        control.layer.cornerRadius = 20

        control.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        let icon = Icon(icon: Asset.attachFile.image, iconWidth: 15)

        bag += isOpenSignal.atOnce().animated(style: SpringAnimationStyle.heavyBounce()) { isOpen in
            icon.transform = CGAffineTransform(rotationAngle: CGFloat(radians(isOpen ? 45 : 0)))
        }

        control.addSubview(icon)

        icon.snp.makeConstraints { make in
            make.width.height.equalTo(15)
            make.center.equalToSuperview()
        }

        let touchUpInside = control.signal(for: .touchUpInside)

        bag += touchUpInside.feedback(type: .impactLight)

        bag += control.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
            control.backgroundColor = UIColor.hedvig(.primaryTintColor).darkened(amount: 0.1)
        }

        bag += merge(
            touchUpInside,
            control.signal(for: .touchCancel),
            control.signal(for: .touchUpOutside)
        ).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
            control.backgroundColor = UIColor.hedvig(.primaryTintColor)
        }

        return (control, Signal { callback in
            bag += touchUpInside.onValue(callback)
            return bag
        })
    }
}
