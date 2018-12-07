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

        let view = UIView()
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 15)

        let existingMemberButton = ExistingMemberButton {
            self.resultCallbacker.callAll(with: .login)
        }
        bag += view.add(existingMemberButton)

        let newMemberButton = NewMemberButton {
            self.resultCallbacker.callAll(with: .onboard)
        }
        bag += view.add(newMemberButton)

        bag += events.wasAdded.delay(by: 0.75).animatedOnValue(style: AnimationStyle.easeOut(duration: 0.25)) {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        }

        bag += events.wasAdded.onValue {
            view.snp.makeConstraints({ make in
                guard let superview = view.superview else { return }
                make.width.equalToSuperview().inset(10)
                make.centerX.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(superview.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalToSuperview()
                }
                make.height.equalTo(40)
            })
        }

        return (view, bag)
    }
}
