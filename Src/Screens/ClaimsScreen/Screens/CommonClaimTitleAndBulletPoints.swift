//
//  CommonClaimTitleAndBulletPoints.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-15.
//

import Foundation
import Flow
import Presentation
import UIKit
import Form

struct CommonClaimTitleAndBulletPoints {
    let commonClaimCard: CommonClaimCard
    let originView: UIView
}

extension CommonClaimTitleAndBulletPoints: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        
        let bag = DisposeBag()
     
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = .offWhite
        
        let pan = UIPanGestureRecognizer()
        
        bag += view.install(pan)
        
        commonClaimCard.backgroundStateSignal.value = .expanded
        commonClaimCard.cornerRadiusSignal.value = 0
        commonClaimCard.iconTopPaddingStateSignal.value = .expanded
        commonClaimCard.titleLabelStateSignal.value = .expanded
        commonClaimCard.layoutTitleAlphaSignal.value = 1
        commonClaimCard.controlIsEnabledSignal.value = false
        commonClaimCard.shadowOpacitySignal.value = 0
        
        bag += view.addArangedSubview(commonClaimCard) { view in
            view.snp.makeConstraints({ make in
                make.height.equalTo(commonClaimCard.height(state: .expanded))
            })
        }
        
        bag += view.addArangedSubview(BulletPointTable(
            bulletPoints: commonClaimCard.data.layout.asTitleAndBulletPoints!.bulletPoints
        ))
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += self.commonClaimCard.closeSignal.onValue {
                completion(.success)
            }
            
            return DelayedDisposer(bag, delay: 1)
        })
    }
}
