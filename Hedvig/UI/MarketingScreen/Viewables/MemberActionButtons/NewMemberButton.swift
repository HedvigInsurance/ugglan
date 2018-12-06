//
//  NewMemberButton.swift
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

struct NewMemberButton {
    let onTap: () -> Void
}

extension NewMemberButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton(title: "Ny här?", style: .standardWhite)
        button.adjustsImageWhenHighlighted = false

        bag += button.on(event: .touchDown).map({ _ -> ButtonStyle in
            .standardWhiteHighlighted
        }).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        bag += button.on(event: .touchDown).feedback(type: .selection)

        bag += button.on(event: .touchUpInside).map({ _ -> ButtonStyle in
            .standardWhite
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
                make.width.equalToSuperview().multipliedBy(0.5).inset(2.5)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
                make.height.equalTo(40)
            })
        }

        return (button, bag)
    }
}
