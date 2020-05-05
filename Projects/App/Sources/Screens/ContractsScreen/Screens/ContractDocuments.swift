//
//  ContractDocuments.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-18.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct ContractDocuments {
    let contract: ContractsQuery.Data.Contract
}

extension ContractDocuments: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = String(key: .INSURANCE_PAGE_MY_DOCUMENTS_TITLE)
        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection()
        section.dynamicStyle = .sectionPlain

        let certificateRow = ButtonRow(text: String(key: .MY_DOCUMENTS_INSURANCE_CERTIFICATE), style: .normalButton)
        bag += section.append(certificateRow)

        bag += certificateRow.onSelect.onValue { _ in
            guard let url = URL(string: self.contract.currentAgreement.certificateUrl) else {
                return
            }

            viewController.present(
                InsuranceDocument(url: url, title: String(key: .MY_DOCUMENTS_INSURANCE_CERTIFICATE)),
                style: .default,
                options: [.defaults, .allowSwipeDismissAlways]
            )
        }

        let insuranceTermsRow = ButtonRow(text: contract.termsAndConditions.displayName, style: .normalButton)
        bag += section.append(insuranceTermsRow)

        bag += insuranceTermsRow.onSelect.onValue { _ in
            guard let url = URL(string: self.contract.termsAndConditions.url) else {
                return
            }

            viewController.present(
                InsuranceDocument(url: url, title: self.contract.termsAndConditions.displayName),
                style: .default,
                options: [.defaults, .allowSwipeDismissAlways]
            )
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
