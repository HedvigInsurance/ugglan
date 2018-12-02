//
//  SkipToNextButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct SkipToNextButton {
    let collectionKit: CollectionKit<EmptySection, MarketingStory>
}

extension SkipToNextButton: Viewable {
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()

        let skipToNextButton = UIButton(title: "Nästa", style: .invisible)

        bag += skipToNextButton.on(event: .touchDown).feedback(type: .impactLight)

        bag += skipToNextButton.throttle(0.5).onValue {
            self.collectionKit.scrollToNextItem()
        }

        return (skipToNextButton, bag)
    }

    func makeConstraints(make: ConstraintMaker) {
        make.width.equalToSuperview()
        make.right.equalTo(0)
        make.top.equalTo(0)
        make.height.equalToSuperview().inset(30)
    }
}
