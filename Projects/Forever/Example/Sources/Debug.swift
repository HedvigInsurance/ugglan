//
//  Debug.swift
//  ForeverExample
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Forever
import ForeverTesting
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

        bag += section.appendRow(title: "Advanced main tab screen").onValue {
            bag += viewController.present(
                ReflectionForm(type: ForeverData.self, title: "Advanced"),
                style: .default,
                options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            ).onValue { data in
                let service = MockForeverService(data: data)
                bag += viewController.present(Forever(service: service))
            }
        }

        bag += section.appendRow(title: "Main tab screen").onValue {
            let data = ForeverData(
                grossAmount: .sek(100),
                netAmount: .sek(50),
                potentialDiscountAmount: .sek(10),
                discountCode: "HJQ123",
                invitations: []
            )
            let service = MockForeverService(data: data)
            viewController.present(
                Forever(service: service),
                style: .default,
                options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            )
        }

        bag += section.appendRow(title: "Invitation screen").onValue {
            viewController.present(InvitationScreen(), style: .modal, options: [])
        }

        bag += section.appendRow(title: "PieChart debugger").onValue {
            viewController.present(PieChartDebugger())
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
