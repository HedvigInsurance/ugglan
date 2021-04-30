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

struct StartDate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let form = FormView()
        
        return (viewController, bag)
    }
}
