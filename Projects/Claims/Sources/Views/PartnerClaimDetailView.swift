import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct PartnerClaimDetailView: View {
    @StateObject private var vm: PartnerClaimDetailViewModel

    public init(claim: ClaimModel?, claimId: String) {
        _vm = .init(wrappedValue: .init(claim: claim, claimId: claimId))
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding8) {
                if let claim = vm.claim {
                    claimCardSection(claim: claim)
                    statusContextSection
                    claimDetailsSection(claim: claim)
                    contactSection(handlerEmail: claim.handlerEmail)
                    documentSection(claim: claim)
                }
            }
        }
        .detent(
            item: $vm.document,
            presentationStyle: .detent(style: [.large])
        ) { document in
            PDFPreview(document: document)
        }
        .loading($vm.processingState)
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(buttonAction: {
                    vm.fetchClaimDetails()
                })
            )
        )
    }

    private func claimCardSection(claim: ClaimModel) -> some View {
        hSection {
            ClaimStatusCard(
                claim: claim,
                enableTap: false
            )
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var statusContextSection: some View {
        if let statusParagraph = vm.claim?.statusParagraph {
            hSection {
                hRow {
                    hText(statusParagraph, style: .body1)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    private func claimDetailsSection(claim: ClaimModel) -> some View {
        let filteredItems = claim.displayItems.filter { $0.displayValue != "" }
        if !filteredItems.isEmpty {
            VStack(spacing: .padding16) {
                hSection {
                    VStack(spacing: .padding8) {
                        ForEach(filteredItems) { item in
                            HStack {
                                hText(item.displayTitle)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                                Spacer()
                                hText(item.displayValue)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
                .withHeader(
                    title: L10n.ClaimStatus.ClaimDetails.title,
                    infoButtonDescription: L10n.ClaimStatus.ClaimDetails.infoText
                )
                .hWithoutDivider
                .sectionContainerStyle(.transparent)
            }
            .padding(.vertical, .padding8)
        }
    }

    @ViewBuilder
    private func contactSection(handlerEmail: String?) -> some View {
        if let handlerEmail {
            hSection {
                hRow {
                    HStack {
                        hText(handlerEmail)
                        Spacer()
                        hCoreUIAssets.arrowNorthEast.view
                    }
                }
                .withEmptyAccessory
                .onTap {
                    if let url = URL(string: "mailto:\(handlerEmail)") {
                        Dependencies.urlOpener.open(url)
                    }
                }
            }
            .withHeader(title: L10n.ClaimStatusDetail.MessageView.body)
        }
    }

    @ViewBuilder
    private func documentSection(claim: ClaimModel) -> some View {
        let termsDocument = claim.productVariant?.documents
            .first(where: { $0.type == .termsAndConditions })
        if let termsDocument {
            InsuranceTermView(
                documents: [termsDocument],
                withHeader: L10n.ClaimStatusDetail.Documents.title
            ) { [weak vm] document in
                vm?.document = document
            }
        }
    }
}

@MainActor
class PartnerClaimDetailViewModel: ObservableObject {
    @Published var claim: ClaimModel?
    @Published var document: hPDFDocument?
    @Published var processingState: ProcessingState = .loading
    private var claimDetailsService: FetchClaimDetailsService

    init(claim: ClaimModel?, claimId: String) {
        self.claim = claim
        self.claimDetailsService = .init(id: claimId)
        if claim != nil {
            processingState = .success
        } else {
            fetchClaimDetails()
        }
    }

    func fetchClaimDetails() {
        processingState = .loading
        Task {
            do {
                let claim = try await claimDetailsService.getPartnerClaim()
                self.claim = claim
                processingState = .success
            } catch {
                processingState = .error(errorMessage: error.localizedDescription)
            }
        }
    }
}
