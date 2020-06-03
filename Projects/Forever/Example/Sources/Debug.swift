//
//  Debug.swift
//  ForeverExample
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Forever
import Form
import Foundation
import Presentation
import UIKit

struct Debug {}

extension Debug: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Forever Example"

        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection(headerView: UILabel(value: "Screens", style: .default), footerView: nil)

        bag += section.appendRow(title: "Main tab screen").onValue {
            viewController.present(Forever(), style: .modal, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += section.appendRow(title: "Invitation screen").onValue {
            viewController.present(InvitationScreen(), style: .modal, options: [])
        }

        bag += section.appendRow(title: "Infinite loop").onValue {
            viewController.present(Debug(), style: .modal, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
