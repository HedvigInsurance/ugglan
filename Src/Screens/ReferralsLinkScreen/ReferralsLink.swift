//
//  ReferralsInvitation.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-10.
//

import Foundation
import Flow
import Presentation
import UIKit

enum ReferralsLinkResult {
    case accept, decline
}

struct ReferralsLink {}

extension ReferralsLink: Presentable {
    func materialize() -> (UIViewController, Future<ReferralsLinkResult>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        
        let view = UIView()
        view.backgroundColor = UIColor.offWhite
        
        let content = ReferralsLinkContent()
        
        bag += view.add(content) { view in
            view.snp.makeConstraints({ make in
                make.top.bottom.trailing.leading.equalToSuperview()
            })
        }
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += content.didTapDecline.onValue { _ in
                completion(.success(.decline))
            }
            
            bag += content.didTapAccept.onValue { _ in
                completion(.success(.accept))
            }
            
            return DelayedDisposer(bag, delay: 2)
        })
    }
}
