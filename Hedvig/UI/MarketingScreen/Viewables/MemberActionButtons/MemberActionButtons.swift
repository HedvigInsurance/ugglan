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
    let collectionKit: CollectionKit<EmptySection, MarketingStory>
}

extension MemberActionButtons: Viewable {
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 15)

        let existingMemberButton = ExistingMemberButton(collectionKit: collectionKit)
        bag += view.add(existingMemberButton)

        let newMemberButton = NewMemberButton(collectionKit: collectionKit)
        bag += view.add(newMemberButton)

        return (view, bag)
    }

    func animateIn(view: UIView) {
        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseOut, animations: {
            view.transform = CGAffineTransform.identity
            view.alpha = 1
        }, completion: nil)
    }

    func makeConstraints(make: ConstraintMaker) {
        make.width.equalTo(collectionKit.view).inset(10)
        make.centerX.equalTo(collectionKit.view)
        make.bottom.equalTo(collectionKit.view).inset(15)
        make.height.equalTo(40)
    }
}
