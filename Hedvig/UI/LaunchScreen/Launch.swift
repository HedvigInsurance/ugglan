//
//  Launch.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-09.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import INTUAnimationEngine
import Lottie
import Presentation
import UIKit

struct Launch {}

extension Launch: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        let containerView = UIView()
        containerView.backgroundColor = HedvigColors.white
        viewController.view = containerView

        let animationView = LOTAnimationView(name: "WordmarkAnimation")
        animationView.contentMode = .scaleAspectFit

        containerView.addSubview(animationView)

        animationView.snp.makeConstraints { make in
            make.width.equalTo(210)
            make.height.equalTo(85)
            make.centerX.equalToSuperview().offset(-1)
            make.centerY.equalToSuperview().offset(-21)
        }

        animationView.play(fromProgress: 1, toProgress: 0, withCompletion: nil)

        return (viewController, Future { completion in

            bag += containerView.didMoveToWindowSignal.delay(
                by: 0.6
            ).animated(
                style: SpringAnimationStyle.lightBounce()
            ) { progress in
                let scale = INTUInterpolateCGFloat(1, 0.9, progress)
                animationView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }.animated(
                style: SpringAnimationStyle.lightBounce()
            ) { progress in
                containerView.alpha = INTUInterpolateCGFloat(1, 0, progress)
                let scale = INTUInterpolateCGFloat(0.9, 1.3, progress)
                animationView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }.onValue { _ in
                completion(.success(()))
            }

            return bag
        })
    }
}
