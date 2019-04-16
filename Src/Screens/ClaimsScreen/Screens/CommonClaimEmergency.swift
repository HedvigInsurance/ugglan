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
    let layout: CommonClaimsQuery.Data.CommonClaim.Layout.AsEmergency
}

extension CommonClaimEmergency: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = ""
        
        let view = UIView()
        view.backgroundColor = .offWhite
        
        viewController.view = view
        
        let bag = DisposeBag()
        return (viewController, bag)
    }
}
