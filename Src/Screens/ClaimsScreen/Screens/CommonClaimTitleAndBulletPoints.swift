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
}

extension CommonClaimTitleAndBulletPoints: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = commonClaimCard.data.layout.asTitleAndBulletPoints?.title
        
        let bag = DisposeBag()
     
        let view = UIView()
        view.backgroundColor = .offWhite
        
        commonClaimCard.backgroundColorSignal.value = UIColor.pink.lighter(amount: 0.1)
        commonClaimCard.cornerRadiusSignal.value = 0
        commonClaimCard.iconTopPaddingSignal.value = 50
        commonClaimCard.titleAlphaSignal.value = 0
        commonClaimCard.layoutTitleAlphaSignal.value = 1
        commonClaimCard.controlIsEnabledSignal.value = false
        commonClaimCard.shadowOpacitySignal.value = 0
        
        bag += view.add(commonClaimCard) { view in
            view.snp.makeConstraints({ make in
                make.width.equalToSuperview()
                make.height.equalTo(265)
                make.top.equalToSuperview()
                make.left.equalToSuperview()
            })
        }
        
        let button = Button(title: "test", type: .standard(backgroundColor: .pink, textColor: .white))
        bag += view.add(button) { view in
            view.snp.makeConstraints({ make in
                make.bottom.equalToSuperview().inset(30)
            })
        }
    
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += button.onTapSignal.onValue {
                completion(.success)
            }
            return bag
        })
    }
}
