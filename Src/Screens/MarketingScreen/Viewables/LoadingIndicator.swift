//
//  LoadingIndicator.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-17.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct LoadingIndicator {
    let showAfter: TimeInterval
    let color: UIColor
    
    init(showAfter: TimeInterval, color: UIColor = .white) {
        self.showAfter = showAfter
        self.color = color
    }
}

extension LoadingIndicator: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.alpha = 0
        loadingIndicator.color = color

        loadingIndicator.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.center.equalToSuperview()
        }

        let bag = DisposeBag()

        bag += Signal(after: showAfter).animated(style: AnimationStyle.easeOut(duration: 0.5), animations: {
            loadingIndicator.alpha = 1
            loadingIndicator.startAnimating()
        })

        return (loadingIndicator, bag)
    }
}
