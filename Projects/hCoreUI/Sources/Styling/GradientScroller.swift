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
            
            bag += traitCollectionSignal.atOnce().onValue({ traitCollection in
                if #available(iOS 13.0, *) {
                    if traitCollection.userInterfaceLevel == .elevated {
                        gradientLayer.isHidden = true
                        return
                    } else {
                        gradientLayer.isHidden = false
                    }
                }
                
                if traitCollection.userInterfaceStyle == .dark {
                    gradientLayer.colors = [
                        UIColor(red: 0.745, green: 0.608, blue: 0.953, alpha: 0.55).cgColor,
                        UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0).cgColor
                    ]
                } else {
                    gradientLayer.colors = [
                        UIColor(red: 0.863, green: 0.871, blue: 0.961, alpha: 1).cgColor,
                        UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 0).cgColor
                    ]
                }
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
