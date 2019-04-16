//
//  CardControllerTransitioningDelegate.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-15.
//

import Foundation
import UIKit

class CardControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let originView: UIView
    let commonClaimCard: CommonClaimCard
    
    init(originView: UIView, commonClaimCard: CommonClaimCard) {
        self.originView = originView
        self.commonClaimCard = commonClaimCard
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardAnimationController(originView: originView, commonClaimCard: commonClaimCard)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissCardAnimationController(originView: originView, commonClaimCard: commonClaimCard)
    }
}
