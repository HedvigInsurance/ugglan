//
//  Debug.swift
//  ForeverExample
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Form
import Presentation
import UIKit
import Flow
import Forever

struct Debug {}

extension Debug: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Forever Example"
        
        let bag = DisposeBag()
        
        let form = FormView()
        
        let section = form.appendSection(headerView: UILabel(value: "Forever", style: .brand(.footnote(color: .primary))), footerView: nil)
        
        bag += section.appendRow(title: "Present main screen").onValue {
            viewController.present(Forever())
        }
        
        bag += section.appendRow(title: "Present invitation screen").onValue {
            viewController.present(InvitationScreen(), style: .modal)
        }
        
        bag += viewController.install(form)
        
        return (viewController, bag)
    }
}
