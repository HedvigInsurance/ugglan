//
//  SkipToPreviousButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import FlowFeedback
import Form
import Foundation
import SnapKit
import UIKit

struct SkipToPreviousButton {
    let onScrollToPrevious: () -> Void
}

extension SkipToPreviousButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton(title: "Tidigare", style: .invisible)

        bag += button.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += button.throttle(0.5).onValue(onScrollToPrevious)

        bag += events.wasAdded.onValue {
            button.snp.makeConstraints({ make in
                make.width.equalToSuperview().multipliedBy(0.25)
                make.height.equalToSuperview().inset(60)
                make.top.equalToSuperview()
                make.left.equalToSuperview()
            })
        }

        return (button, bag)
    }
}
