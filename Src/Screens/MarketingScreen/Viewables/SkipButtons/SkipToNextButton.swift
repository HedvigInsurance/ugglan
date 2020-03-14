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
    let pausedCallbacker: Callbacker<Bool>
    let onScrollToNext: () -> Void
}

extension SkipToNextButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton(title: "Nästa", style: .invisible)

        bag += button.signal(for: .touchDown).onValue { _ in
            let timeAtTouchDown = Date()

            let pauseBag = DisposeBag()

            pauseBag += Signal(after: 0.15).onValue { _ in
                self.pausedCallbacker.callAll(with: true)
            }

            pauseBag += button.signal(for: .touchUpInside).onValue { _ in
                if Date().timeIntervalSince(timeAtTouchDown) < 0.15 {
                    self.onScrollToNext()
                    bag += Signal(after: 0).feedback(type: .impactLight)
                } else {
                    self.pausedCallbacker.callAll(with: false)
                }

                pauseBag.dispose()
            }

            bag += pauseBag
        }

        bag += events.wasAdded.onValue {
            button.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.right.equalTo(0)
                make.top.equalTo(0)
                make.height.equalToSuperview().inset(60)
            }
        }

        return (button, bag)
    }
}
