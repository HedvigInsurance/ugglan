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

    var subTitle: String {
        switch self {
        case .certificate:
            return L10n.myDoumentsInsurancePrepurchaseSubtitle
        case .terms:
            return L10n.myDocumentsInsuranceTermsSubtitle
        }
    }

    func url(from contract: Contract) -> URL? {
        switch self {
        case .certificate:
            return URL(string: contract.currentAgreement?.certificateUrl)
        case .terms:
            return URL(string: contract.termsAndConditions.url)
        }
    }
}

struct ContractDocumentsView: View {
    @PresentableStore var store: ContractStore

    let id: String

    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract = contract {
                ForEach(Documents.allCases, id: \.title) { document in
                    hSection {
                        if let url = document.url(from: contract) {
                            hRow {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 1) {
                                        hText(document.title)
                                        if #available(iOS 16.0, *) {
                                            hText(L10n.documentPdfLabel, style: .footnote)
                                                .baselineOffset(6.0)
                                        }
                                    }
                                    hText(document.subTitle)
                                        .foregroundColor(hTextColorNew.secondary)
                                }
                            }
                            .withCustomAccessory {
                                Spacer()
                                Image(uiImage: hCoreUIAssets.neArrowSmall.image)
                            }
                            .onTap {
                                store.send(
                                    .contractDetailNavigationAction(action: .document(url: url, title: document.title))
                                )
                            }
                        }
                    }
                }
            }
        }
        if hAnalyticsExperiment.terminationFlow {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.contractForId(id)
                }
            ) { contract in
                if (contract?.currentAgreement?.activeTo) == nil {
                    hSection {
                        hButton.SmallButtonText {
                            store.send(.startTermination(contractId: id))
                        } content: {
                            hText(L10n.terminationButton, style: .body)
                                .foregroundColor(hTextColorNew.secondary)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}
