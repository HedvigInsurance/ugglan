import Combine
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import TerminateContracts
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractDocumentsView: View {
    @PresentableStore var contractStore: ContractStore
    let id: String
    @State var height: CGFloat = 0
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract = contract {
                VStack(spacing: 4) {
                    ForEach(getDocumentsToDisplay(contract: contract), id: \.displayName) { document in
                        if let url = URL(string: document.url) {
                            hSection {
                                hRow {
                                    hAttributedTextView(
                                        text: AttributedPDF().attributedPDFString(for: document.displayName)
                                    )
                                    .id("sds_\(document.displayName)")
                                }
                                .withCustomAccessory {
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
    }

    func getDocumentsToDisplay(contract: Contract) -> [InsuranceTerm] {
        var documents: [InsuranceTerm] = []
        contract.currentAgreement?.productVariant.documents
            .forEach { document in
                documents.append(document)
            }
        let certficateUrl = InsuranceTerm(
            displayName: L10n.myDocumentsInsuranceCertificate,
            url: contract.currentAgreement?.certificateUrl ?? "",
            type: .unknown
        )
        documents.append(certficateUrl)
        return documents
    }
}

private class ContractsDocumentViewModel: ObservableObject {
    var cancellable: AnyCancellable?
}
