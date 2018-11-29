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

        bag += skipToNextButton.onValue {
            self.collectionKit.scrollToNextItem()
        }

        return (skipToNextButton, bag)
    }

    func makeConstraints(make: ConstraintMaker) {
        make.width.equalTo(50)
        make.height.equalTo(collectionKit.view.snp.height).inset(30)
        make.top.equalTo(collectionKit.view.snp.top)
        make.right.equalTo(collectionKit.view.snp.right)
    }
}
