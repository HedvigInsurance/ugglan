//
//  Logo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-03.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

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

        bag += events.wasAdded.onValue {
            wordmarkIcon.snp.makeConstraints({ make in
                make.center.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            })

            view.snp.makeConstraints({ make in
                guard let superview = view.superview else { return }
                if #available(iOS 11.0, *) {
                    make.top.equalTo(superview.safeAreaLayoutGuide.snp.top).inset(5)
                } else {
                    make.top.equalToSuperview().inset(5)
                }
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(50)
            })
        }

        return (view, bag)
    }
}
