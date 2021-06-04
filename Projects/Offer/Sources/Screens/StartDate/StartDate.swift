//
//  StartDate.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-30.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow
import Presentation
import Form
import hCore

struct StartDate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.offerSetStartDate
        let bag = DisposeBag()
        
        let form = FormView()
        bag += viewController.install(form)
        
        return (viewController, bag)
    }
}
