import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractDocuments { let contract: Contract }

extension ContractDocuments: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.insurancePageMyDocumentsTitle
        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection()
        section.dynamicStyle = .brandGroupedInset(separatorType: .standard)

        func showSections() {
            if let certUrlString = contract.currentAgreement?.certificateUrl, let url = URL(string: certUrlString) {
                let certificateRow = RowView(
                    title: L10n.myDocumentsInsuranceCertificate,
                    style: .brand(.body(color: .primary))
                )
                certificateRow.append(hCoreUIAssets.chevronRight.image)

                bag += section.append(certificateRow)
                    .onValue { _ in
                        viewController.present(
                            Document(url: url, title: L10n.myDocumentsInsuranceCertificate)
                                .withCloseButton,
                            style: .detented(.large)
                        )
                    }
            }

            if let url = URL(string: contract.termsAndConditions.url) {
                let insuranceTermsRow = RowView(
                    title: L10n.myDocumentsInsuranceTerms,
                    style: .brand(.body(color: .primary))
                )
                insuranceTermsRow.append(hCoreUIAssets.chevronRight.image)

                bag += section.append(insuranceTermsRow)
                    .onValue { _ in
                        viewController.present(
                            Document(url: url, title: L10n.myDocumentsInsuranceTerms)
                                .withCloseButton,
                            style: .detented(.large)
                        )
                    }
            }
        }

        showSections()
        bag += viewController.install(form, options: [])

        return (viewController, bag)
    }
}
