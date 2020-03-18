//
//  PerilDetail.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-18.
//

import Foundation
import Presentation
import UIKit
import Flow
import Form

struct PerilDetail {
    let title: String
    let description: String
}

extension PerilDetail: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let form = FormView()
        
        form.append(UILabel(value: title, style: .headlineLargeLargeLeft))
        bag += form.append(Spacing(height: 10))
        bag += form.append(MultilineLabel(value: description, style: .bodySmallSmallLeft))
        
        bag += viewController.install(form)
        
        return (viewController, bag)
    }
}
