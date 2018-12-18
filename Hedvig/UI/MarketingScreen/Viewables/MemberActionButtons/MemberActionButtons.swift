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
        stackView.spacing = 15

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
            style: SpringAnimationStyle.lightBounce()
        ) {
            stackView.alpha = 1
            stackView.transform = CGAffineTransform.identity
        }

        bag += stackView.makeConstraints(wasAdded: events.wasAdded).onValue { make, safeArea in
            make.width.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeArea)
        }

        return (stackView, bag)
    }
}
