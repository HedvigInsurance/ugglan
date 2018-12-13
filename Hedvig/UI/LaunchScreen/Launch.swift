//
//  Launch.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-09.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit

#if canImport(Lottie)
    import Lottie
#endif

struct Launch {
    let hasLoadedSignal: Signal<Void>
}

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

        animationView.play(fromProgress: 1, toProgress: 1, withCompletion: nil)

        return (viewController, Future { completion in

            bag += self.hasLoadedSignal.onValue({ _ in
                animationView.play(fromProgress: 1, toProgress: 0, withCompletion: nil)
            })

            bag += self.hasLoadedSignal.delay(
                by: 0.6
            ).animated(
                style: AnimationStyle.easeOut(duration: 0.5)
            ) {
                animationView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }.animated(
                style: AnimationStyle.easeOut(duration: 0.5)
            ) {
                containerView.alpha = 0
                animationView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }.onValue { _ in
                completion(.success(()))
            }

            return bag
        })
    }
}
