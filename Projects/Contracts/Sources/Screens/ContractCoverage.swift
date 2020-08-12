//
//  ContractCoverage.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-17.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct ContractCoverage {
    let perilFragments: [GraphQL.PerilFragment]
    let insurableLimitFragments: [GraphQL.InsurableLimitFragment]
}

extension ContractCoverage: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = L10n.contractCoverageMainTitle

        let form = FormView()
        form.backgroundColor = .brand(.secondaryBackground())

        bag += form.append(ContractPerilCollection(presentDetailStyle: .default, perilFragmentsSignal: ReadWriteSignal(perilFragments).readOnly()))

        bag += form.append(Spacing(height: 20))

        bag += form.append(Divider(backgroundColor: .brand(.primaryBorderColor)))

        bag += form.append(Spacing(height: 20))

        bag += form.append(MultilineLabel(
            value: L10n.contractCoverageMoreInfo,
            style: .brand(.headline(color: .primary))
        ))

        bag += form.append(Spacing(height: 10))

        bag += form.append(ContractInsurableLimits(insurableLimitFragmentsSignal: ReadWriteSignal(insurableLimitFragments).readOnly()))

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
