import SwiftUI
import hCore
import hCoreUI

public struct ClaimHistory: View {
    @ObservedObject var vm = ClaimsViewModel()
    var onTap: (ClaimModel) -> Void

    public init(
        onTap: @escaping (ClaimModel) -> Void
    ) {
        self.onTap = onTap
    }

    public var body: some View {
        if vm.claims.isEmpty {
            StateView(
                type: .empty,
                title: L10n.ClaimHistory.EmptyState.title,
                bodyText: L10n.ClaimHistory.EmptyState.body
            )
        } else {
            claimHistoryView
        }
    }

    var claimHistoryView: some View {
        hForm {
            ForEach(vm.claims, id: \.id) { claim in
                hSection {
                    hRow {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                hText(claim.claimType)
                                Spacer()
                                if let outcome = claim.outcome?.text {
                                    hPill(text: outcome, color: .clear)
                                }
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
                .sectionContainerStyle(.transparent)
                .hWithoutHorizontalPadding([.row])
            }
        }
    }

    func getSubTitle(for claim: ClaimModel) -> String? {
        guard let submittedAt = claim.submittedAt else { return nil }
        return L10n.ClaimStatus.ClaimDetails.submitted + " "
            + (submittedAt.localDateToIso8601Date?.displayDateMMMMDDYYYYFormat ?? "")
    }
}

#Preview {
    ClaimHistory(onTap: { _ in })
}
