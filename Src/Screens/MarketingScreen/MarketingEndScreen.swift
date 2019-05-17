//
//  MarketingEndScreen.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import DeviceKit
import Flow
import Form
import Presentation
import SnapKit
import UIKit

struct MarketingEnd {
    let didResult: Callbacker<MarketingResult>
}

extension MarketingEnd: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let blurEffect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0

        bag += effectView.contentView.didMoveToWindowSignal.delay(by: 0.15).animated(
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

        let panGestureRecognizer = UIPanGestureRecognizer()
        bag += containerView.install(panGestureRecognizer)

        let getTargetHeight = {
            containerView.bounds.height * 0.30
        }

        let cancelSignal = panGestureRecognizer.signal(forState: .ended)
            .filter(predicate: { _ -> Bool in
                let translation = panGestureRecognizer.translation(in: containerView)
                let velocity = panGestureRecognizer.velocity(in: containerView)

                return translation.y < getTargetHeight() &&
                    velocity.y < getTargetHeight()
            })

        let dismissSignal = panGestureRecognizer.signal(forState: .ended)
            .filter(predicate: { _ -> Bool in
                let translation = panGestureRecognizer.translation(in: containerView)
                let velocity = panGestureRecognizer.velocity(in: containerView)

                return translation.y > getTargetHeight() ||
                    velocity.y > getTargetHeight()
            })

        bag += cancelSignal.animated(
            mapStyle: {
                Device.hasRoundedCorners ?
                    AnimationStyle.easeOut(duration: 0, delay: 0.25) :
                    AnimationStyle.easeOut(duration: 0.25)
            },
            animations: { _ in
                containerView.layer.mask = nil
            }
        )

        bag += cancelSignal
            .map { _ -> CGAffineTransform in
                CGAffineTransform.identity
            }.bindTo(animate: AnimationStyle.easeOut(duration: 0.25), containerView, \.transform)

        bag += dismissSignal.animated(mapStyle: { _ -> SpringAnimationStyle in
            let velocity = panGestureRecognizer.velocity(in: containerView)

            return SpringAnimationStyle(
                duration: 0.8,
                damping: 20,
                velocity: max(velocity.y / containerView.bounds.height, 0.8),
                delay: 0
            )
        }, animations: { _ in
            containerView.transform = containerView.transform.concatenating(
                CGAffineTransform(
                    translationX: 0,
                    y: containerView.bounds.height
                )
            )
        })

        // set scale while panning
        bag += panGestureRecognizer.signal(forState: .changed).map { _ -> CGAffineTransform in
            let translation = panGestureRecognizer.translation(in: containerView)

            let scale = max(1 - (translation.y / (containerView.bounds.height * 4)), 0.5)
            return CGAffineTransform(scaleX: min(scale, 1), y: min(scale, 1))
        }.bindTo(containerView, \.transform)

        // set rounded corners when panning has started
        bag += panGestureRecognizer.signal(forState: .changed).onValue { _ in
            let translation = panGestureRecognizer.translation(in: containerView)

            if translation.y > 0 {
                let targetCornerRadii: CGFloat = Device.hasRoundedCorners ? 38.5 : 15
                let targetTranslationY: CGFloat = Device.hasRoundedCorners ? 1 : 50
                let cornerRadii = min(translation.y / targetTranslationY, 1) * targetCornerRadii

                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(
                    roundedRect: containerView.bounds,
                    byRoundingCorners: .allCorners,
                    cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)
                ).cgPath

                containerView.layer.mask = maskLayer
            } else {
                containerView.layer.mask = nil
            }
        }

        return (viewController, Future { completion in
            let end = End(
                dismissSignal: dismissSignal
            )

            bag += containerView.add(end).onValue { marketingResult in
                let intent: OnboardingChat.Intent = marketingResult == .onboard ? .onboard : .login
                bag += viewController.present(OnboardingChat(intent: intent), options: [.prefersNavigationBarHidden(false)])
            }

            bag += dismissSignal.onValue { _ in
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 0.2)
        })
    }
}
