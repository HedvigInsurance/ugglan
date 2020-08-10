//
//  FormScrollView.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow

public final class FormScrollView: UIScrollView {
    let bag = DisposeBag()
    
    public override func didMoveToWindow() {
        guard bag.isEmpty else {
            return
        }
        
        if let navigationController = self.viewController?.navigationController {
            if navigationController.viewControllers.count != 1 {
                return
            }
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.locations = [0, 1]
            gradientLayer.startPoint = CGPoint.zero
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            
            let originalTransform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
            gradientLayer.transform = CATransform3DMakeAffineTransform(originalTransform)
            
            self.layer.insertSublayer(gradientLayer, at: 0)
            
            bag += {
                gradientLayer.removeFromSuperlayer()
            }
            
            bag += didLayoutSignal.onValue({ _ in
                gradientLayer.frame = self.bounds
            })
            
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
            
            bag += signal(for: \.contentOffset).onValue { contentOffset in
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let layerInsetY = min(contentOffset.y + self.safeAreaInsets.top, 0)
                gradientLayer.frame = self.bounds.insetBy(dx: 0, dy: layerInsetY)
                CATransaction.commit()
            }
        }
    }
}
