import Combine
import Foundation
import PresentableStore
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

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
                InsuranceTermView(
                    documents: getDocumentsToDisplay(contract: contract)
                ) { document in
                    contractsNavigationViewModel.document = document
                }
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
