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
                        hSection {
                            if let url = URL(string: document.url) {
                                hRow {
                                    VStack(alignment: .leading, spacing: 0) {
                                        if #available(iOS 15.0, *) {
                                            Text(attributedPDFString(for: document.displayName))
                                        } else {
                                            HStack(spacing: 1) {
                                                hText(document.displayName)
                                                if #available(iOS 16.0, *) {
                                                    hText(L10n.documentPdfLabel, style: .footnote)
                                                        .baselineOffset(6.0)
                                                }
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
    }

    @available(iOS 15, *)
    private func attributedPDFString(for title: String) -> AttributedString {
        let schema = ColorScheme(UITraitCollection.current.userInterfaceStyle) ?? .light
        let attributes = AttributeContainer(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .standard),
                NSAttributedString.Key.foregroundColor: hTextColor.primary.colorFor(schema, .base).color.uiColor(),
            ]
        )

        var result = AttributedString(title, attributes: attributes)

        let pdfAddonAttribures = AttributeContainer(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .standardExtraSmall),
                NSAttributedString.Key.foregroundColor: hTextColor.primary.colorFor(schema, .base).color.uiColor(),
                NSAttributedString.Key.baselineOffset: 6,
            ]
        )
        var pdfAddon = AttributedString(" \(L10n.documentPdfLabel)", attributes: pdfAddonAttribures)
        result.append(pdfAddon)
        return result
    }

    func getDocumentsToDisplay(contract: Contract) -> [InsuranceTerm] {
        var documents: [InsuranceTerm] = []
        contract.currentAgreement?.productVariant.documents
            .forEach { document in
                documents.append(document)
            }
        let certficateUrl = InsuranceTerm(
            displayName: L10n.myDocumentsInsuranceCertificate,
            url: contract.currentAgreement?.certificateUrl ?? ""
        )
        documents.append(certficateUrl)
        return documents
    }
}
private class ContractsDocumentViewModel: ObservableObject {
    var cancellable: AnyCancellable?
}
