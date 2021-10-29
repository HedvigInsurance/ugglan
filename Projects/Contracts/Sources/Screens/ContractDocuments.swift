import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

enum Documents: CaseIterable {
    case certificate, terms
    
    var title: String {
        switch self {
        case .certificate:
            return L10n.myDocumentsInsuranceCertificate
        case .terms:
            return L10n.myDocumentsInsuranceTerms
        }
    }
    
    func url(from contract: Contract) -> URL? {
        switch self {
        case .certificate:
            return URL(string: contract.currentAgreement.certificateUrl)
        case .terms:
            return URL(string: contract.termsAndConditions.url)
        }
    }
}

struct ContractDocumentsView: View {
    @PresentableStore var store: ContractStore
    
    let contract: Contract
    
    var body: some View {
        hSection {
            ForEach(Documents.allCases, id: \.self) { document in
                if let url = document.url(from: contract) {
                    hRow {
                        hText(document.title)
                    }.withCustomAccessory {
                        Spacer()
                        Image(uiImage: hCoreUIAssets.chevronRight.image)
                    }
                    .onTap {
                        store.send(.contractDetailNavigationAction(action: .document(url: url, title: document.title)))
                    }
                }
            }
        }
    }
}

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
            if let url = URL(string: contract.currentAgreement.certificateUrl) {
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
