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
        
        if let bulletPoints = commonClaimCard.data.layout.asTitleAndBulletPoints?.bulletPoints {
            bag += view.addArangedSubview(BulletPointTable(
                bulletPoints: bulletPoints
            )) { tableView in
                bag += tableView.didLayoutSignal.onValue({ _ in
                    tableView.snp.remakeConstraints({ make in
                        make.height.equalTo(tableView.contentSize.height + 20)
                    })
                })
            }
        }
        
        bag += viewController.install(view) { scrollView in
            bag += scrollView.contentOffsetSignal.bindTo(self.commonClaimCard.scrollPositionSignal)
            
            if #available(iOS 11.0, *) {
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
