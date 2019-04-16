//
//  DismissCardAnimationController.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-16.
//

import Foundation
import UIKit
import Flow

class DismissCardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originView: UIView
    private let commonClaimCard: CommonClaimCard
    private let bag = DisposeBag()
    
    init(originView: UIView, commonClaimCard: CommonClaimCard) {
        self.originView = originView
        self.commonClaimCard = commonClaimCard
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let contentContainerView = UIView()
        contentContainerView.alpha = 0
        
        let claimsCardFinalHeight: CGFloat = 265
        
        transitionContext.containerView.addSubview(contentContainerView)

        contentContainerView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        contentContainerView.layoutIfNeeded()
        
        let originFrame = originView.convert(originView.frame, to: transitionContext.containerView)
        
        self.commonClaimCard.backgroundColorSignal.value = UIColor.pink.lighter(amount: 0.1)
        self.commonClaimCard.cornerRadiusSignal.value = 0
        self.commonClaimCard.iconTopPaddingSignal.value = 50
        self.commonClaimCard.titleAlphaSignal.value = 0
        self.commonClaimCard.layoutTitleAlphaSignal.value = 1
        
        bag += contentContainerView.add(commonClaimCard) { view in
            view.snp.makeConstraints ({ make in
                make.height.equalTo(claimsCardFinalHeight)
                make.width.equalTo(contentContainerView.frame.width)
                make.top.equalTo(0)
                make.left.equalTo(0)
            })
            
            bag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.1), animations: { _ in
                self.commonClaimCard.layoutTitleAlphaSignal.value = 0
            })
            
            bag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                self.commonClaimCard.backgroundColorSignal.value = UIColor.white
                self.commonClaimCard.cornerRadiusSignal.value = 8
                self.commonClaimCard.iconTopPaddingSignal.value = 15
                self.commonClaimCard.titleAlphaSignal.value = 1
                
                view.snp.updateConstraints ({ make in
                    make.height.equalTo(originFrame.height)
                    make.width.equalTo(originFrame.width)
                    make.top.equalTo(originFrame.origin.y)
                    make.left.equalTo(originFrame.origin.x)
                })
                
                view.layoutIfNeeded()
                contentContainerView.layoutIfNeeded()
            }
        }
        
        let contentView = UIView()
        contentView.alpha = 1
        contentView.backgroundColor = .offWhite
        
        contentContainerView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(contentContainerView.frame.height - claimsCardFinalHeight)
            make.width.equalTo(contentContainerView.frame.width)
            make.top.equalTo(claimsCardFinalHeight)
            make.left.equalTo(0)
        }
        
        bag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            contentView.snp.updateConstraints ({ make in
                make.height.equalTo(0)
                make.width.equalTo(originFrame.width)
                make.top.equalTo(originFrame.maxY)
                make.left.equalTo(originFrame.origin.x)
            })
            
            contentView.layoutIfNeeded()
            contentContainerView.layoutIfNeeded()
        }
        
        contentContainerView.layoutIfNeeded()
        
        let fromVC = transitionContext.viewController(forKey: .from)
        fromVC?.view.alpha = 0
        contentContainerView.alpha = 1
        
        bag += Signal(after: 1).onValue {
            self.originView.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}
