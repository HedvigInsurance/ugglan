//
//  MemberActionButtons.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct MemberActionButtons {
    let resultCallbacker: Callbacker<MarketingResult>
}

extension MemberActionButtons: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 20

        stackView.alpha = 0
        stackView.transform = CGAffineTransform(translationX: 0, y: 15)

        let newMemberButton = NewMemberButton(style: .marketingScreen) {
            self.resultCallbacker.callAll(with: .onboard)
        }
        bag += stackView.addArangedSubview(newMemberButton)

        let existingMemberButton = ExistingMemberButton {
            self.resultCallbacker.callAll(with: .login)
        }
        bag += stackView.addArangedSubview(existingMemberButton)

        _ = stackView.didMoveToWindowSignal.delay(by: 0.75).animated(
            style: AnimationStyle.easeOut(duration: 0.25)
        ) {
            stackView.alpha = 1
            stackView.transform = CGAffineTransform.identity
        }

        bag += events.wasAdded.onValue {
            stackView.snp.makeConstraints({ make in
                guard let superview = stackView.superview else { return }
                make.width.equalToSuperview().inset(10)
                make.centerX.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(superview.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalToSuperview()
                }
            })
        }

        return (stackView, bag)
    }
}
