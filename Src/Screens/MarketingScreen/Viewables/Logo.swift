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
import ComponentKit

struct Logo {
    let pausedSignal: Signal<Bool>
}

extension Logo: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let wordmarkIcon = Icon(frame: .zero, icon: Asset.wordmarkWhite.image, iconWidth: 90)
        view.addSubview(wordmarkIcon)

        wordmarkIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        bag += pausedSignal.onValue { paused in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                view.alpha = paused ? 0 : 1
            }, completion: nil)
        }
        
        bag += view.didMoveToWindowSignal.take(first: 1).onValue { _ in
            view.snp.makeConstraints { make in
                if Device.hasRoundedCorners {
                    make.top.equalTo(view.safeAreaLayoutGuide).offset(5)
                } else {
                    make.top.equalTo(25)
                }

                make.centerX.equalToSuperview()
                make.width.equalTo(90)
                make.height.equalTo(40)
                wordmarkIcon.layoutSubviews()
            }
        }

        return (view, bag)
    }
}
