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

struct ContractCoverage {
    let perilFragments: [PerilFragment]
    let insurableLimitFragments: [InsurableLimitFragment]
}

extension ContractCoverage: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = String(key: .CONTRACT_COVERAGE_MAIN_TITLE)

        let form = FormView()
        form.backgroundColor = .secondaryBackground

        bag += form.append(ContractPerilCollection(presentDetailStyle: .default, perilFragmentsSignal: ReadWriteSignal(perilFragments).readOnly()))

        bag += form.append(Spacing(height: 20))

        bag += form.append(Divider(backgroundColor: .lightGray))

        bag += form.append(Spacing(height: 20))

        bag += form.append(MultilineLabel(value: String(key: .CONTRACT_COVERAGE_MORE_INFO), style: .headlineSmallSmallLeft))

        bag += form.append(Spacing(height: 10))

        bag += form.append(ContractInsurableLimits(insurableLimitFragmentsSignal: ReadWriteSignal(insurableLimitFragments).readOnly()))

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
