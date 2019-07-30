//
//  AttachFileButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-26.
//

import Foundation
import Flow
import UIKit

struct AttachFileButton {
    let isOpenSignal: ReadSignal<Bool>
}

extension AttachFileButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIControl, Signal<Void>) {
        let bag = DisposeBag()
        let control = UIControl()
        control.backgroundColor = .purple
        control.layer.cornerRadius = 17.5
        
        control.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        
        let icon = Icon(icon: Asset.arrowUp, iconWidth: 15)
        icon.image.tintColor = UIColor.white
        
        bag += isOpenSignal.atOnce().map({ isOpen -> ImageAsset in
            isOpen ? Asset.close : Asset.arrowUp
        }).bindTo(
            transition: icon,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            icon,
            \.icon
        )
        
        bag += isOpenSignal.atOnce().map({ isOpen -> CGFloat in
            isOpen ? 10 : 15
        }).bindTo(
            transition: icon,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            icon,
            \.iconWidth
        )
        
        control.addSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(15)
            make.center.equalToSuperview()
        }
        
        let touchUpInside = control.signal(for: .touchUpInside)
        
        bag += touchUpInside.feedback(type: .impactLight)
        
        bag += control.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
            control.backgroundColor = UIColor.purple.darkened(amount: 0.1)
        }
        
        bag += merge(
            touchUpInside,
            control.signal(for: .touchCancel),
            control.signal(for: .touchUpOutside)
            ).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                control.backgroundColor = UIColor.purple
        }
        
        return (control, Signal { callback in
            bag += touchUpInside.onValue(callback)
            return bag
        })
    }
}
