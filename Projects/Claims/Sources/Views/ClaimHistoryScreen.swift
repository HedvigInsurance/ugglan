import AppStateContainer
import Combine
import SwiftUI
import hCore
import hCoreUI

public struct ClaimHistoryScreen: View {
    @AppState var store: ClaimsStore
    var onTap: (ClaimModel) -> Void

    public init(
        onTap: @escaping (ClaimModel) -> Void
    ) {
        self.onTap = onTap
    }

    public var body: some View {
        Group {
            if store.historyClaims.isEmpty {
                StateView(
                    type: .empty,
                    title: L10n.ClaimHistory.EmptyState.title,
                    bodyText: L10n.ClaimHistory.EmptyState.body,
                    formPosition: .center
                )
            } else {
                claimHistoryView
            }
        }
        .task {
            await store.fetchHistoryClaims()
        }
    }

    var claimHistoryView: some View {
        hForm {
            hSection(store.historyClaims) { claim in
                hRow {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            hText(claim.claimType)
                            Spacer()
                            hPill(text: claim.outcome?.text ?? L10n.Claim.StatusBar.closed, color: .clear)
                                .hFieldSize(.small)
                        }
                        if let submittedAt = getSubTitle(for: claim) {
                            hText(submittedAt, style: .label)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                    }
                }
                .withChevronAccessory
                .onTap {
                    onTap(claim)
                }
            }
            .hWithoutHorizontalPadding([.row, .divider])
            .sectionContainerStyle(.transparent)
        }
    }

    func getSubTitle(for claim: ClaimModel) -> String? {
        guard let formatted = claim.submittedAt?.displayDateDDMMMYYYYFormat else { return nil }
        return L10n.ClaimStatus.ClaimDetails.submitted + " " + formatted
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    return ClaimHistoryScreen(onTap: { _ in })
}
