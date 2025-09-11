import Addons
import Combine
import Foundation
import PresentableStore
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI

struct ContractDocumentsView: View {
    @PresentableStore var contractStore: ContractStore
    @EnvironmentObject private var contractsNavigationViewModel: ContractsNavigationViewModel

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
                VStack(alignment: .leading, spacing: .padding8) {
                    InsuranceTermView(
                        documents: getDocumentsToDisplay(contract: contract)
                    ) { document in
                        contractsNavigationViewModel.document = document
                    }

                    if let addonVariant = contract.currentAgreement?.addonVariant {
                        ForEach(addonVariant, id: \.self) { addonVariant in
                            addonDocumentSection(for: addonVariant)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func addonDocumentSection(for addonVariant: AddonVariant) -> some View {
        if !addonVariant.documents.isEmpty {
            hSection {
                hPill(text: addonVariant.displayName, color: .blue)
                    .hFieldSize(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, .padding24)

            InsuranceTermView(
                documents: addonVariant.documents
            ) { document in
                contractsNavigationViewModel.document = document
            }
        }
    }

    func getDocumentsToDisplay(contract: Contract) -> [hPDFDocument] {
        var documents: [hPDFDocument] = []
        contract.currentAgreement?.productVariant.documents
            .forEach { document in
                documents.append(document)
            }
        let certficateUrl = hPDFDocument(
            displayName: L10n.myDocumentsInsuranceCertificate,
            url: contract.currentAgreement?.certificateUrl ?? "",
            type: .unknown
        )
        documents.append(certficateUrl)
        return documents
    }
}

@MainActor
private class ContractsDocumentViewModel: ObservableObject {
    var cancellable: AnyCancellable?
}
