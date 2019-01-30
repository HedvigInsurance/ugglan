//
//  BubbleLoading.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-23.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit

struct BubbleLoading {
    let originatingView: UIView
    let dismissSignal: Signal<Void>

    init(originatingView: UIView, dismissSignal: Signal<Void>) {
        self.originatingView = originatingView
        self.dismissSignal = dismissSignal
    }
}

class LightContentViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}

extension BubbleLoading: Presentable {
    func materialize() -> (LightContentViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = LightContentViewController()

        let bubbleView = UIView()
        bubbleView.backgroundColor = .purple

        let containerView = UIView()
        containerView.addSubview(bubbleView)

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.style = .whiteLarge
        activityIndicator.alpha = 0

        containerView.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints({ make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        })

        viewController.view = containerView

        let originatingPoint = originatingView.convert(
            CGPoint(x: originatingView.frame.width / 2, y: originatingView.frame.height / 2),
            to: containerView
        )

        bubbleView.frame = CGRect(
            x: originatingPoint.x,
            y: originatingPoint.y,
            width: 0.1,
            height: 0.1
        )

        bubbleView.layer.cornerRadius = bubbleView.frame.height / 2

        return (viewController, Future { completion in
            bag += Signal(after: 0.1).animated(
                style: AnimationStyle.easeOut(duration: 0.3)
            ) { _ in
                let scaleX = (UIScreen.main.bounds.height / bubbleView.frame.width) * 2
                let scaleY = (UIScreen.main.bounds.height / bubbleView.frame.height) * 2

                bubbleView.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            }.animated(style: AnimationStyle.easeOut(duration: 0.5)) {
                activityIndicator.alpha = 1
            }

            bag += self.dismissSignal.delay(by: 1).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                activityIndicator.alpha = 0
            }.animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                bubbleView.alpha = 0
            }.onValue({ _ in
                completion(.success)
            })

            return bag
        })
    }
}
