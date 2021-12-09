import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

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

    let id: String

    var body: some View {
        PresentableStoreLens(ContractStore.self, getter: { state in
            state.contractForId(id)
        }) { contract in
            if let contract = contract {
        hSection(Documents.allCases, id: \.title) { document in
            if let url = document.url(from: contract) {
                hRow {
                    hText(document.title)
                }
                .withCustomAccessory {
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
}
