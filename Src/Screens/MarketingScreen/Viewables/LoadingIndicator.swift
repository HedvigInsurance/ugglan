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
import ComponentKit

struct LoadingIndicator {
    let showAfter: TimeInterval
    let color: UIColor
    let size: CGFloat

    private static let defaultLoaderColor = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark ? .hedvig(.white) : .hedvig(.primaryTintColor)
    })

    init(showAfter: TimeInterval, color: UIColor = LoadingIndicator.defaultLoaderColor, size: CGFloat = 100) {
        self.showAfter = showAfter
        self.color = color
        self.size = size
    }
}

extension LoadingIndicator: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.alpha = 0
        loadingIndicator.color = color
        
        let bag = DisposeBag()

        bag += loadingIndicator.didMoveToWindowSignal.take(first: 1).onValue { _ in
            loadingIndicator.snp.makeConstraints { make in
                make.width.equalTo(self.size)
                make.height.equalTo(self.size)
                make.center.equalToSuperview()
            }
        }

        bag += Signal(after: showAfter).animated(style: AnimationStyle.easeOut(duration: 0.5), animations: {
            loadingIndicator.alpha = 1
            loadingIndicator.startAnimating()
        })

        return (loadingIndicator, bag)
    }
}
