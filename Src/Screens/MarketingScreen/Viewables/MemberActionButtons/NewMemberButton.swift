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
    static let newMemberButtonEndScreen = SharedElementIdentity<UIView>(
        identifier: "newMemberButtonEndScreen"
    )
    static let newMemberButtonMarketingScreen = SharedElementIdentity<UIView>(
        identifier: "newMemberButtonMarketingScreen"
    )
}

extension NewMemberButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let button = Button(
            title: "Skaffa TEST",
            type: .standard(
                backgroundColor: style == .endScreen ? .purple : .white,
                textColor: style == .endScreen ? .white : .black
            )
        )

        if style == .endScreen {
            bag += SharedElement.register(
                for: SharedElementIdentities.newMemberButtonEndScreen,
                view: view
            )
        } else {
            bag += SharedElement.register(
                for: SharedElementIdentities.newMemberButtonMarketingScreen,
                view: view
            )
        }

        bag += view.add(button)

        bag += button.onTapSignal.onValue {
            self.onTap()
        }

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.height.equalTo(button.type.height())
        }

        return (view, bag)
    }
}
