//
//  CardAnimationController.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-15.
//

import Foundation
import UIKit
import Flow

class CardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originView: UIView
    private let commonClaimCard: CommonClaimCard
    private let bag = DisposeBag()
    
    init(originView: UIView, commonClaimCard: CommonClaimCard) {
        self.originView = originView
        self.commonClaimCard = commonClaimCard
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let contentContainerView = UIView()
        let claimsCardFinalHeight = commonClaimCard.height(state: .expanded)
        
        transitionContext.containerView.addSubview(contentContainerView)
        
        contentContainerView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        let originFrame = originView.convert(originView.frame, to: transitionContext.containerView)
        
        bag += contentContainerView.add(commonClaimCard) { view in
            self.originView.alpha = 0
            
            view.snp.makeConstraints({ make in
                make.height.equalTo(originFrame.height)
                make.width.equalTo(originFrame.width)
                make.top.equalTo(originFrame.origin.y)
                make.left.equalTo(originFrame.origin.x)
            })
            
            view.layoutIfNeeded()
            
            bag += Signal(after: 0.0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                view.snp.updateConstraints({ make in
                    make.height.equalTo(claimsCardFinalHeight)
                    make.width.equalTo(contentContainerView.frame.width)
                    make.top.equalTo(0)
                    make.left.equalTo(0)
                })

                self.commonClaimCard.backgroundColorSignal.value = UIColor.pink.lighter(amount: 0.1)
                self.commonClaimCard.cornerRadiusSignal.value = 0
                self.commonClaimCard.iconTopPaddingStateSignal.value = .expanded
                self.commonClaimCard.titleLabelStateSignal.value = .expanded
                self.commonClaimCard.shadowOpacitySignal.value = 0
                
                view.layoutIfNeeded()
                contentContainerView.layoutIfNeeded()
            }
            
            bag += Signal(after: 0.3).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                self.commonClaimCard.layoutTitleAlphaSignal.value = 1
            }
        }
        
        
        let bulletPointCollection = BulletPointCollection(
            bulletPoints: self.commonClaimCard.data.layout.asTitleAndBulletPoints!.bulletPoints
        )
        
        bag += contentContainerView.add(bulletPointCollection) { contentView in
            contentView.snp.makeConstraints { make in
                make.height.equalTo(0)
                make.width.equalTo(originFrame.width)
                make.top.equalTo(originFrame.maxY)
                make.left.equalTo(originFrame.origin.x)
            }
            
            contentView.layoutIfNeeded()
            
            bag += Signal(after: 0.0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                contentView.snp.updateConstraints { make in
                    make.height.equalTo(contentContainerView.frame.height - claimsCardFinalHeight)
                    make.width.equalTo(contentContainerView.frame.width)
                    make.top.equalTo(claimsCardFinalHeight)
                    make.left.equalTo(0)
                }
                
                contentView.layer.cornerRadius = 0
                
                contentView.layoutIfNeeded()
                contentContainerView.layoutIfNeeded()
            }
        }
        
        
        bag += Signal(after: transitionDuration(using: transitionContext)).onValue {
            transitionContext.containerView.addSubview(toVC.view)

            toVC.view.snp.makeConstraints({ make in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
                make.center.equalToSuperview()
            })
            transitionContext.containerView.addSubview(toVC.view)
            contentContainerView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
