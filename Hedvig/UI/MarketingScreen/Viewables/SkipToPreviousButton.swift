//
//  SkipToPreviousButton.swift
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

struct SkipToPreviousButton {
    let collectionKit: CollectionKit<EmptySection, MarketingStory>
}

extension SkipToPreviousButton: Viewable {
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()

        let skipToPreviousButton = UIButton(title: "Tidigare", style: .invisible)

        bag += skipToPreviousButton.on(event: .touchDown).feedback(type: .impactLight)

        return (skipToPreviousButton, bag)
    }

    func makeConstraints(make: ConstraintMaker) {
        make.width.equalTo(50)
        make.height.equalTo(collectionKit.view.snp.height).inset(30)
        make.top.equalTo(collectionKit.view.snp.top)
        make.left.equalTo(collectionKit.view.snp.left)
    }
}
