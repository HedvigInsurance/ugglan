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

enum NewMemberButtonStyle {
    case marketingScreen, endScreen
}

struct NewMemberButton {
    let style: NewMemberButtonStyle
    let onTap: () -> Void
}

extension SharedElementIdentities {
    static let newMemberButtonEndScreen = SharedElementIdentity<UIButton>(
        identifier: "newMemberButtonEndScreen"
    )
    static let newMemberButtonMarketingScreen = SharedElementIdentity<UIButton>(
        identifier: "newMemberButtonMarketingScreen"
    )
}

extension NewMemberButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let button = UIButton()
        button.adjustsImageWhenHighlighted = false

        if style == .endScreen {
            bag += SharedElement.register(for: SharedElementIdentities.newMemberButtonEndScreen, view: button)
            button.style = .standardPurple
            button.setTitle("Skaffa Hedvig")
        } else {
            bag += SharedElement.register(for: SharedElementIdentities.newMemberButtonMarketingScreen, view: button)
            button.style = .standardWhite
            button.setTitle("Skaffa Hedvig")
        }

        bag += button.on(event: .touchDown).map({ _ -> ButtonStyle in
            self.style == .endScreen ? .standardPurpleHighlighted : .standardWhiteHighlighted
        }).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        bag += button.on(event: .touchDown).feedback(type: .selection)

        bag += button.on(event: .touchUpInside).map({ _ -> ButtonStyle in
            self.style == .endScreen ? .standardPurple : .standardWhite
        }).delay(by: 0.1).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        bag += button.on(event: .touchUpOutside).map({ _ -> ButtonStyle in
            self.style == .endScreen ? .standardPurple : .standardWhite
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
                make.width.equalTo(button.intrinsicContentSize.width + 60)
                make.height.equalTo(50)
            })
        }

        return (button, bag)
    }
}
