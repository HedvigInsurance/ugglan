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

        let view = UIView()

        let button = Button(
            title: "Redan medlem? Logga in",
            type: .pillTransparent(backgroundColor: .darkGray, textColor: .white)
        )

        bag += button.onTapSignal.onValue {
            self.onTap()
        }

        bag += view.add(button)

        bag += events.wasAdded.onValue {
            view.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(button.type.height())
                make.width.equalToSuperview()
            })
        }

        return (view, bag)
    }
}
