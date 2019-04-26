//
//  CommonClaimEmergency.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-15.
//

import Foundation
import Flow
import Presentation
import UIKit

struct CommonClaimEmergency {
    let commonClaimCard: CommonClaimCard
}

extension CommonClaimEmergency: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = ""
        viewController.automaticallyAdjustsScrollViewInsets = false
        
        let bag = DisposeBag()
        
        let view = UIStackView()
        view.axis = .vertical
        
        commonClaimCard.backgroundStateSignal.value = .expanded
        commonClaimCard.cornerRadiusSignal.value = 0
        commonClaimCard.iconTopPaddingStateSignal.value = .expanded
        commonClaimCard.titleLabelStateSignal.value = .expanded
        commonClaimCard.layoutTitleAlphaSignal.value = 1
        commonClaimCard.controlIsEnabledSignal.value = false
        commonClaimCard.shadowOpacitySignal.value = 0
        commonClaimCard.showCloseButton.value = true
        commonClaimCard.showClaimButtonSignal.value = true
        
        bag += view.addArangedSubview(commonClaimCard) { commonClaimCardView in
            commonClaimCardView.snp.makeConstraints({ make in
                make.height.equalTo(commonClaimCard.height(state: .expanded))
            })
            
            bag += commonClaimCardView.didLayoutSignal.onValue({ _ in
                view.bringSubviewToFront(commonClaimCardView)
            })
        }
        
        let emergencyActions = EmergencyActions()
        bag += view.addArangedSubview(emergencyActions) { emergencyActionsView in
            bag += emergencyActionsView.didLayoutSignal.onValue({ _ in
                emergencyActionsView.snp.remakeConstraints({ make in
                    make.height.equalTo(emergencyActionsView.contentSize.height + 20)
                })
            })
        }
        
        bag += viewController.install(view) { scrollView in
            bag += scrollView.contentOffsetSignal.bindTo(self.commonClaimCard.scrollPositionSignal)
            
            if #available(iOS 11.0, *) {
                scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 90, left: 0, bottom: 40, right: 0)
                scrollView.insetsLayoutMarginsFromSafeArea = false
                scrollView.contentInsetAdjustmentBehavior = .never
            }
        }
        
        return (viewController, Future { completion in
            bag += self.commonClaimCard.closeSignal.onValue {
                completion(.success)
            }
            
            return DelayedDisposer(bag, delay: 1)
        })
    }
}
