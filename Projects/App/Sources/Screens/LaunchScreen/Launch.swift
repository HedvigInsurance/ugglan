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
import hCore

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
            bag += self.hasLoadedSignal.delay(
                by: 0.6
            ).animated(
                style: AnimationStyle.easeOut(duration: 0.5)
            ) {
                imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }.animated(
                style: AnimationStyle.easeOut(duration: 0.5)
            ) {
                containerView.alpha = 0
                imageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }.onValue { _ in
                completion(.success(()))
            }

            return bag
        })
    }
}
