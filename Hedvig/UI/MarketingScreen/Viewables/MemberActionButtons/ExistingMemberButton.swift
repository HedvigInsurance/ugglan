//
//  ExistingMemberButton.swift
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

struct ExistingMemberButton {
    let collectionKit: CollectionKit<EmptySection, MarketingStory>
}

extension ExistingMemberButton: Viewable {
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton(title: "Logga in", style: .standardTransparentBlack)
        button.transform = CGAffineTransform(translationX: 0, y: 15)
        button.adjustsImageWhenHighlighted = false
        button.alpha = 0

        bag += button.on(event: .touchDown).map({ _ -> ButtonStyle in
            .standardTransparentBlackHighlighted
        }).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        bag += button.on(event: .touchDown).feedback(type: .selection)

        bag += button.on(event: .touchUpInside).map({ _ -> ButtonStyle in
            .standardTransparentBlack
        }).delay(by: 0.1).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        return (button, bag)
    }

    func animateIn(view: UIView) {
        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseOut, animations: {
            view.transform = CGAffineTransform.identity
            view.alpha = 1
        }, completion: nil)
    }

    func makeConstraints(make: ConstraintMaker) {
        make.width.equalToSuperview().multipliedBy(0.5).inset(2.5)
        make.left.equalTo(0)
        make.bottom.equalTo(0)
        make.height.equalTo(40)
    }
}
