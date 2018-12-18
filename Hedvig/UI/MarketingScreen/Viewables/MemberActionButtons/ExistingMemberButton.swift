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
    let onTap: () -> Void
}

extension ExistingMemberButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton(title: "Redan medlem? Logga in", style: .pillTransparentGray)
        button.adjustsImageWhenHighlighted = false

        bag += button.on(event: .touchDown).map({ _ -> ButtonStyle in
            .pillTransparentGrayHighlighted
        }).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        bag += button.on(event: .touchDown).feedback(type: .selection)

        bag += combineLatest(
            button.on(event: .touchUpInside),
            button.on(event: .touchUpOutside)
        ).map({ _ -> ButtonStyle in
            .pillTransparentGray
        }).delay(by: 0.1).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        bag += button.on(event: .touchUpInside).onValue({ _ in
            self.onTap()
        })

        bag += events.wasAdded.onValue {
            button.snp.makeConstraints({ make in
                make.width.equalTo(button.intrinsicContentSize.width + 30)
                make.height.equalTo(30)
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
            })
        }

        return (button, bag)
    }
}
