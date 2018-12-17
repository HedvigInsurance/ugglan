//
//  HappyAvatar.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-13.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

#if canImport(Lottie)
    import Lottie
#endif

struct HappyAvatar {}

extension HappyAvatar: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIView()

        let animationView = LOTAnimationView(name: "HappyAvatarAnimation")
        animationView.contentMode = .scaleAspectFit
        animationView.sizeToFit()
        animationView.alpha = 0

        containerView.addSubview(animationView)

        animationView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(22)
        }

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(100)
            make.width.equalTo(100)
        }

        let bag = DisposeBag()

        bag += containerView.didMoveToWindowSignal.delay(by: 0.15).onValue { _ in
            animationView.alpha = 1
            animationView.play()
        }

        return (containerView, bag)
    }
}
