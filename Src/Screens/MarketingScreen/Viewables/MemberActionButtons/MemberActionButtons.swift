//
//  MemberActionButtons.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import DeviceKit
import Flow
import Form
import Foundation
import SnapKit
import UIKit
import ComponentKit

struct MemberActionButtons {
    let resultCallbacker: Callbacker<MarketingResult>
    let pausedSignal: Signal<Bool>
}

extension MemberActionButtons: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 15

        stackView.alpha = 0
        stackView.transform = CGAffineTransform(translationX: 0, y: 15)

        bag += pausedSignal.onValue { paused in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                stackView.alpha = paused ? 0 : 1
            }, completion: nil)
        }

        let newMemberButton = NewMemberButton(style: .marketingScreen) {
            self.resultCallbacker.callAll(with: .onboard)
        }
        bag += stackView.addArranged(newMemberButton)

        let existingMemberButton = ExistingMemberButton {
            self.resultCallbacker.callAll(with: .login)
        }
        bag += stackView.addArranged(existingMemberButton)

        bag += stackView.didMoveToWindowSignal.animated(
            style: SpringAnimationStyle.lightBounce()
        ) {
            stackView.alpha = 1
            stackView.transform = CGAffineTransform.identity
        }

        bag += stackView.didMoveToWindowSignal.take(first: 1).onValue({ _ in
            stackView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(10)
                make.centerX.equalToSuperview()

                if Device.hasRoundedCorners {
                    make.bottom.equalTo(stackView.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalTo(-15)
                }
            }
        })

        return (stackView, bag)
    }
}
