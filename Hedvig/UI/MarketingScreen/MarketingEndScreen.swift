//
//  MarketingEndScreen.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import SnapKit
import UIKit

struct MarketingEnd {}

extension MarketingEnd: Presentable {
    func materialize() -> (UIViewController, Future<MarketingResult?>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let blurEffect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0

        _ = effectView.contentView.didMoveToWindowSignal.delay(by: 0.15).animated(
            style: AnimationStyle.easeOut(duration: 0.25)
        ) {
            effectView.alpha = 1
        }

        let containerView = UIView()
        containerView.addSubview(effectView)

        effectView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        viewController.view = containerView

        let panGesture = containerView.panGesture()

        bag += panGesture.filter(predicate: { $0.state == .ended })
            .filter(predicate: { pan -> Bool in
                let translation = pan.translation(in: containerView)
                return translation.y < (containerView.bounds.height * 0.25)
            })
            .map({ _ -> CGAffineTransform in
                CGAffineTransform.identity
            }).bindTo(animate: AnimationStyle.easeOut(duration: 0.25), containerView, \.transform)

        let dismissGesture = panGesture.filter(predicate: { $0.state == .ended })
            .filter(predicate: { pan -> Bool in
                let translation = pan.translation(in: containerView)
                return translation.y > (containerView.bounds.height * 0.25)
            })

        bag += dismissGesture.animated(mapStyle: { pan -> SpringAnimationStyle in
            let velocity = pan.velocity(in: containerView)
            return SpringAnimationStyle(
                duration: 0.8,
                damping: 20,
                velocity: velocity.y / containerView.bounds.height,
                delay: 0
            )
        }, animations: {
            containerView.transform = containerView.transform.concatenating(
                CGAffineTransform(
                    translationX: 0,
                    y: containerView.bounds.height
                )
            )
        })

        bag += panGesture.filter(predicate: { $0.state != .ended }).map({ pan -> CGAffineTransform in
            let translation = pan.translation(in: containerView)

            if pan.state == .changed {
                let scale = max(1 - (translation.y / (containerView.frame.height * 4)), 0.5)
                return CGAffineTransform(scaleX: min(scale, 1), y: min(scale, 1))
            }

            return CGAffineTransform.identity
        }).bindTo(containerView, \.transform)

        bag += containerView.didMoveToWindowSignal.onValue { _ in
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(
                roundedRect: containerView.bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: 38.5, height: 38.5)
            ).cgPath

            containerView.layer.mask = maskLayer
        }

        return (viewController, Future { completion in
            let end = End(
                dismissGesture: dismissGesture
            )

            bag += containerView.add(end)

            bag += dismissGesture.delay(by: 0.5).onValue { _ in
                completion(.success(nil))
            }

            return bag
        })
    }
}
