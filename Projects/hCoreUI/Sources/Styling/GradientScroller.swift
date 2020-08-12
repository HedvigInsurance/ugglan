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

protocol GradientScroller where Self: UIScrollView {}

extension GradientScroller {
    func addGradient(into bag: DisposeBag) {
        guard bag.isEmpty else {
            return
        }
                
        if let navigationController = self.viewController?.navigationController {
            if navigationController.viewControllers.count != 1 {
                return
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
            
            bag += didLayoutSignal.onValue {
                gradientLayer.frame = self.bounds
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
                animation.duration = 0.5
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
