//
//  SkipToNextButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import FlowOn
import Form
import Foundation
import SnapKit
import UIKit

struct SkipToNextButton {
    let pausedCallbacker: Callbacker<Bool>
    let onScrollToNext: () -> Void
}

extension SkipToNextButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton(title: "Nästa", style: .invisible)

        bag += button.on(event: .touchDown).feedback(type: .impactLight)

        bag += button.on(event: .touchDown).throttle(0.5).onValue({ _ in
            self.pausedCallbacker.callAll(with: true)
            let timeAtTouchDown = Date()

            let pauseBag = DisposeBag()

            pauseBag += button.on(event: .touchUpInside).onValue({ _ in
                pauseBag.dispose()

                if Date().timeIntervalSince(timeAtTouchDown) < 0.15 {
                    self.onScrollToNext()
                }

                self.pausedCallbacker.callAll(with: false)
            })

            bag += pauseBag
        })

        bag += events.wasAdded.onValue {
            button.snp.makeConstraints({ make in
                make.width.equalToSuperview()
                make.right.equalTo(0)
                make.top.equalTo(0)
                make.height.equalToSuperview().inset(50)
            })
        }

        return (button, bag)
    }
}
