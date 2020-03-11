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
import ComponentKit

struct ExistingMemberButton {
    let onTap: () -> Void
}

extension ExistingMemberButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let button = Button(
            title: String(key: .MARKETING_LOGIN),
            type: .pillSemiTransparent(backgroundColor: .hedvig(.darkGray), textColor: .hedvig(.white))
        )

        bag += button.onTapSignal.onValue {
            self.onTap()
        }

        bag += view.add(button) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        bag += events.wasAdded.onValue {
            view.snp.makeConstraints { make in
                make.height.equalTo(button.type.value.height)
                make.width.equalToSuperview()
            }
        }

        return (view, bag)
    }
}
