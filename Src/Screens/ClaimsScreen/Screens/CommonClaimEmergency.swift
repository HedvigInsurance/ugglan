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
        commonClaimCard.showCloseButton.value = true
        commonClaimCard.showClaimButtonSignal.value = true
        
        bag += view.addArangedSubview(commonClaimCard) { view in
            view.snp.makeConstraints({ make in
                make.height.equalTo(commonClaimCard.height(state: .expanded))
            })
        }
        
        let dummyView = UIView()
        dummyView.backgroundColor = .white
        
        view.addArrangedSubview(dummyView)
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += self.commonClaimCard.closeSignal.onValue {
                completion(.success)
            }
            
            return DelayedDisposer(bag, delay: 1)
        })
    }
}
