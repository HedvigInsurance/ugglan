//
//  ContractDocuments.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-18.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct ContractDocuments {
    let contract: GraphQL.ContractsQuery.Data.Contract
}

extension ContractDocuments: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.insurancePageMyDocumentsTitle
        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection()

        let certificateRow = RowView(
            title: L10n.myDocumentsInsuranceCertificate,
            style: .brand(.body(color: .primary))
        )
        certificateRow.append(hCoreUIAssets.chevronRight.image)

        bag += section.append(certificateRow).onValue { _ in
            guard let url = URL(string: self.contract.currentAgreement.certificateUrl) else {
                return
            }

            viewController.present(
                InsuranceDocument(url: url, title: L10n.myDocumentsInsuranceCertificate),
                style: .detented(.large, modally: false)
            )
        }

        let insuranceTermsRow = RowView(
            title: L10n.myDocumentsInsuranceTerms,
            style: .brand(.body(color: .primary))
        )
        insuranceTermsRow.append(hCoreUIAssets.chevronRight.image)

        bag += section.append(insuranceTermsRow).onValue { _ in
            guard let url = URL(string: self.contract.termsAndConditions.url) else {
                return
            }

            viewController.present(
                InsuranceDocument(url: url, title: L10n.myDocumentsInsuranceTerms),
                style: .detented(.large, modally: false)
            )
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
