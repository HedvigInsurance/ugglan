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
import Lottie

struct Launch {
    let hasLoadedSignal: Signal<Void>
}

extension Launch: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        let containerView = UIView()
        containerView.backgroundColor = .primaryBackground
        viewController.view = containerView

        let animationName = viewController.traitCollection.userInterfaceStyle == .dark ? "WordmarkAnimationLight" : "WordmarkAnimation"

        let animationView = LOTAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.animationProgress = 1
        animationView.pause()

        containerView.addSubview(animationView)

        animationView.snp.makeConstraints { make in
            make.width.equalTo(211)
            make.height.equalTo(86)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-3)
        }

        let imageView = UIImageView()
        imageView.image = Asset.wordmark.image
        imageView.contentMode = .scaleAspectFit

        containerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(140)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }

        return (viewController, Future { completion in
            bag += self.hasLoadedSignal.onValue { _ in
                animationView.play(fromProgress: 1, toProgress: 0, withCompletion: nil)
                imageView.alpha = 0
            }

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
