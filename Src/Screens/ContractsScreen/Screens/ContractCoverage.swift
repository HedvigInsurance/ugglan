//
//  ContractCoverage.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-17.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct ContractCoverage {}

extension ContractCoverage: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = "Mitt skydd"

        let form = FormView()
        form.backgroundColor = .secondaryBackground

        bag += form.append(ContractPerilCollection())

        bag += form.append(Spacing(height: 20))

        bag += form.append(Divider(backgroundColor: .lightGray))

        bag += form.append(Spacing(height: 20))

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
