//
//  KeyGearValuation.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-17.
//

import Foundation
import UIKit
import Form
import Flow
import Presentation

struct KeyGearValuation {}

extension KeyGearValuation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_PAGE_TITLE)
        viewController.navigationItem.hidesBackButton = true
        
        let form = FormView()
        
        bag += viewController.install(form)
        
        return (viewController, bag)
    }
}
