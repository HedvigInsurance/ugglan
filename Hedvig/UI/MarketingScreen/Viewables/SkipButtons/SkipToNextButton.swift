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
    let onScrollToNext: () -> Void
}

extension SkipToNextButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton(title: "Nästa", style: .invisible)

        bag += button.on(event: .touchDown).feedback(type: .impactLight)

        bag += button.throttle(0.5).onValue(onScrollToNext)

        bag += events.wasAdded.onValue {
            button.snp.makeConstraints({ make in
                make.width.equalToSuperview()
                make.right.equalTo(0)
                make.top.equalTo(0)
                make.height.equalToSuperview().inset(30)
            })
        }

        return (button, bag)
    }
}
