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

    func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardAnimationController(originView: originView, commonClaimCard: commonClaimCard)
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissCardAnimationController(originView: originView, commonClaimCard: commonClaimCard)
    }
}
