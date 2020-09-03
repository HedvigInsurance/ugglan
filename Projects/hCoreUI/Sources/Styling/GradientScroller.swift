//
//  GradientScroller.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import UIKit

protocol GradientScroller where Self: UIScrollView {}

let colorViewTag = 88888

extension GradientScroller {
    func makeGradientLayer(into bag: DisposeBag) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientLayer"
        gradientLayer.zPosition = -1
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)

        let originalTransform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        gradientLayer.transform = CATransform3DMakeAffineTransform(originalTransform)

        bag += combineLatest(
            traitCollectionSignal.atOnce().plain(),
            ContextGradient.$currentOption.atOnce().latestTwo()
        ).onValue { traitCollection, option in
            if #available(iOS 13.0, *), ContextGradient.rules.contains(.disallowOnElevatedTraits) {
                if traitCollection.userInterfaceLevel == .elevated {
                    gradientLayer.isHidden = true
                    return
                } else {
                    gradientLayer.isHidden = false
                }
            }

            let (prevOption, option) = option

            func optionToColors(_ option: ContextGradient.Option) -> [CGColor] {
                if #available(iOS 13, *) {
                    return option.colors(for: traitCollection).map { $0.resolvedColor(with: traitCollection).cgColor }
                } else {
                    return option.colors(for: traitCollection).map { $0.cgColor }
                }
            }

            gradientLayer.locations = option.locations(for: traitCollection)
            gradientLayer.colors = optionToColors(option)

            let animation = CABasicAnimation(keyPath: "colors")
            animation.fromValue = optionToColors(prevOption)
            animation.toValue = optionToColors(option)
            animation.duration = 1

            gradientLayer.add(animation, forKey: "animateGradient")

            let locationsAnimation = CABasicAnimation(keyPath: "locations")
            locationsAnimation.fromValue = prevOption.locations(for: traitCollection)
            locationsAnimation.toValue = option.locations(for: traitCollection)

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [animation, locationsAnimation]
            animationGroup.duration = 1
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = true
            animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

            gradientLayer.add(animationGroup, forKey: "gradientAnimation")
        }

        bag += combineLatest(
            signal(for: \.contentOffset).atOnce(),
            signal(for: \.bounds).atOnce()
        ).onValue { _, bounds in
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let navigationBarHeight = self.viewController?.navigationController?.navigationBar.frame.height ?? 0

            gradientLayer.transform = CATransform3DMakeAffineTransform(
                originalTransform.concatenating(
                    CGAffineTransform(translationX: 0, y: min(-navigationBarHeight, 0))
                )
            )
            gradientLayer.frame = bounds

            CATransaction.commit()
        }

        return gradientLayer
    }

    func addGradient(into bag: DisposeBag) {
        guard bag.isEmpty else {
            return
        }

        let gradientLayer = makeGradientLayer(into: bag)
        let navigationBarColorView = ContextGradient.makeColorView(into: bag, for: .navigationBar)
        let tabBarColorView = ContextGradient.makeColorView(into: bag, for: .tabBar)

        bag += didMoveToWindowSignal
            .filter(predicate: { !(self.layer.sublayers?.contains(where: { $0.name == "gradientLayer" }) ?? false) })
            .filter(predicate: {
                if ContextGradient.rules.contains(.disallowOnFirstLevelModals) {
                    return self.viewController?.presentingViewController == nil
                }

                return self.viewController?.presentingViewController?.presentingViewController == nil
            })
            .take(first: 1)
            .onValue { _ in
                if let navigationController = self.viewController?.navigationController {
                    if navigationController.viewControllers.count != 1, ContextGradient.rules.contains(.disallowOnNestedViewControllersInNavigationControllers) {
                        return
                    }

                    if navigationController.navigationBar.viewWithTag(colorViewTag) == nil,
                        let barBackgroundView = navigationController.navigationBar.subviews.first {
                        let effectView = barBackgroundView.subviews[1]
                        barBackgroundView.addSubview(navigationBarColorView)

                        navigationBarColorView.snp.makeConstraints { make in
                            make.top.bottom.leading.trailing.equalToSuperview()
                        }

                        navigationBarColorView.alpha = effectView.alpha

                        bag += effectView.signal(for: \.alpha).distinct().onValue { alpha in
                            navigationBarColorView.alpha = alpha
                        }
                    }

                    if let tabBarController = navigationController.tabBarController, tabBarController.tabBar.viewWithTag(colorViewTag) == nil {
                        tabBarController.tabBar.insertSubview(tabBarColorView, at: 0)

                        tabBarColorView.snp.makeConstraints { make in
                            make.top.bottom.leading.trailing.equalToSuperview()
                        }
                    }

                    self.layer.insertSublayer(gradientLayer, at: 0)

                    bag += {
                        gradientLayer.removeFromSuperlayer()
                    }
                }
            }

        layoutIfNeeded()
    }
}
