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
        viewController.title = "Mina dokument"
        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection()
        section.dynamicStyle = .sectionPlain

        let certificateRow = ButtonRow(text: "Försäkringsbrev", style: .normalButton)
        bag += section.append(certificateRow)

        bag += certificateRow.onSelect.onValue { _ in
            guard let url = self.contract.currentAgreement.certificateUrl else {
                return
            }

            viewController.present(
                InsuranceCertificate(url: url),
                style: .default,
                options: [.defaults, .allowSwipeDismissAlways]
            )
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
