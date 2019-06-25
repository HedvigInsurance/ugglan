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
            title: String(key: .MARKETING_GET_HEDVIG),
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

        bag += view.add(button) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        bag += button.onTapSignal.onValue {
            self.onTap()
        }

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(button.type.height())
            make.width.equalToSuperview()
        }

        return (view, bag)
    }
}
