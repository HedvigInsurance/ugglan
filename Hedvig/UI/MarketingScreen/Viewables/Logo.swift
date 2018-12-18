//
//  Logo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-03.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import DeviceKit
import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct Logo {}

extension Logo: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let wordmarkIcon = Icon(frame: .zero, iconName: "WordmarkWhite", iconWidth: 90)
        view.addSubview(wordmarkIcon)

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue { make, safeArea in
            if Device.hasRoundedCorners {
                make.top.equalTo(safeArea.layoutGuide).offset(5)
            } else {
                make.top.equalTo(safeArea.layoutGuide).offset(10)
            }

            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
            wordmarkIcon.layoutSubviews()
        }

        return (view, bag)
    }
}
