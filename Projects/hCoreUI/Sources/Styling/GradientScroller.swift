//
//  GradientScroller.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow
import hCore

protocol GradientScroller where Self: UIScrollView {}

let colorViewTag = 88888

extension GradientScroller {
    func addGradient(into bag: DisposeBag) {
        guard bag.isEmpty else {
            return
        }
                
        if let navigationController = self.viewController?.navigationController {
            if navigationController.viewControllers.count != 1 {
                return
            }
            
            if navigationController.navigationBar.viewWithTag(colorViewTag) == nil,
                let barBackgroundView = navigationController.navigationBar.subviews.first
            {
                let effectView = barBackgroundView.subviews[1]
                
                let colorView = UIView()
                colorView.tag = colorViewTag
                barBackgroundView.addSubview(colorView)
                                
                colorView.snp.makeConstraints { make in
                    make.top.bottom.trailing.leading.equalToSuperview()
                }
                
                colorView.alpha = effectView.alpha
                
                bag += effectView.signal(for: \.alpha).distinct().onValue { alpha in
                    colorView.alpha = alpha
                }
                
                bag += ContextGradient.animateBarColor(colorView)
            }
            
            if let tabBarController = navigationController.tabBarController, tabBarController.tabBar.viewWithTag(colorViewTag) == nil {
                let colorView = UIView()
                colorView.tag = colorViewTag
                tabBarController.tabBar.insertSubview(colorView, at: 0)
                
                colorView.snp.makeConstraints { make in
                    make.top.bottom.leading.trailing.equalToSuperview()
                }
                
                bag += ContextGradient.animateBarColor(colorView)
            }
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.zPosition = -1
            gradientLayer.locations = [0, 1]
            gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
            
            let originalTransform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
            gradientLayer.transform = CATransform3DMakeAffineTransform(originalTransform)
            
            layer.insertSublayer(gradientLayer, at: 0)
            
            bag += {
                gradientLayer.removeFromSuperlayer()
            }
            
            bag += signal(for: \.bounds).atOnce().onValue { bounds in
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                gradientLayer.frame = bounds
                CATransaction.commit()
            }
            
            bag += combineLatest(
                traitCollectionSignal.atOnce().plain(),
                ContextGradient.currentOption.atOnce().latestTwo()
            ).onValue({ traitCollection, option in
                if #available(iOS 13.0, *) {
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
                        return option.colors.map { $0.resolvedColor(with: traitCollection).cgColor }
                    } else {
                        return option.colors.map { $0.cgColor }
                    }
                }
                
                if gradientLayer.colors == nil {
                    gradientLayer.colors = option.colors.map { $0.cgColor }
                    return
                }
                                                                                
                let animation = CABasicAnimation(keyPath: "colors")
                
                gradientLayer.colors = optionToColors(option)

                animation.fromValue = optionToColors(prevOption)
                animation.toValue = optionToColors(option)
                animation.duration = 1
                animation.isRemovedOnCompletion = true
                animation.fillMode = CAMediaTimingFillMode.forwards
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

                gradientLayer.add(animation, forKey:"animateGradient")
            })
            
            bag += signal(for: \.contentOffset).atOnce().onValue { contentOffset in
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let navigationBarHeight = navigationController.navigationBar.frame.height
                
                gradientLayer.transform = CATransform3DMakeAffineTransform(
                    originalTransform.concatenating(
                        CGAffineTransform(translationX: 0, y: min(-navigationBarHeight, 0))
                    )
                )
               
                CATransaction.commit()
            }
        }
    }
}
