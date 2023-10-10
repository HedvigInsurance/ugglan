import Combine
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ContractDocumentsView: View {
    @PresentableStore var contractStore: ContractStore
    let id: String

    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract = contract {
                ForEach(getDocumentsToDisplay(contract: contract), id: \.displayName) { document in
                    hSection {
                        if let url = URL(string: document.url) {
                            hRow {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 1) {
                                        hText(document.displayName)
                                        if #available(iOS 16.0, *) {
                                            hText(L10n.documentPdfLabel, style: .footnote)
                                                .baselineOffset(6.0)
                                        }
                                    }
                                }
                            }
                            .withCustomAccessory {
                                Spacer()
                                Image(uiImage: hCoreUIAssets.neArrowSmall.image)
                            }
                            .onTap {
                                contractStore.send(
                                    .contractDetailNavigationAction(
                                        action: .document(url: url, title: document.displayName)
                                    )
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    func getDocumentsToDisplay(contract: Contract) -> [InsuranceTerm] {
        var documents: [InsuranceTerm] = []
        contract.currentAgreement.productVariant.documents.forEach { document in
            documents.append(document)
        }
        let certficateUrl = InsuranceTerm(
            displayName: L10n.myDocumentsInsuranceCertificate,
            url: contract.currentAgreement.certificateUrl ?? ""
        )
        documents.append(certficateUrl)
        return documents
    }
}
