import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: Claim

    @PresentableStore
    var store: ClaimsStore

    var tapAction: (Claim) -> Void {
        return { claim in
            store.send(.openClaimDetails(claim: claim))

            _ = hAnalyticsEvent.claimCardClick(
                claimId: self.claim.id,
                claimStatus: self.claim.claimDetailData.status.rawValue
            )
        }
    }

    var body: some View {
        CardComponent(
            onSelected: {
                tapAction(claim)
            },
            mainContent: ClaimPills(claim: claim),
            title: claim.title,
            subTitle: claim.subtitle,
            bottomComponent: {
                HStack(spacing: 6) {
                    ForEach(claim.segments, id: \.text) { segment in
                        ClaimStatusBar(status: segment)
                    }
                }
            }
        )
        .trackOnAppear(
            hAnalyticsEvent.claimCardVisible(
                claimId: self.claim.id,
                claimStatus: self.claim.claimDetailData.status.rawValue
            )
        )
    }
}

struct ClaimPills: View {
    var claim: Claim

    var body: some View {
        HStack {
            ForEach(claim.pills, id: \.text) { claimPill in
                claimPill.pill
            }
        }
    }
}

extension Claim.ClaimPill {
    @ViewBuilder
    var pill: some View {
        switch self.type {
        case .open:
            hPillOutline(text: self.text)
        case .closed:
            hPillFill(
                text: text,
                textColor: hLabelColor.primary,
                backgroundColor: hBackgroundColor.primary.inverted
            )
            .invertColorScheme
        case .payment:
            hPillFill(
                text: self.text,
                textColor: hColorScheme(light: hLabelColor.primary, dark: hLabelColor.primary.inverted),
                backgroundColor: hColorScheme(light: hTintColor.lavenderTwo, dark: hTintColor.lavenderOne)
            )
        case .reopened:
            hPillFill(
                text: self.text,
                textColor: hColorScheme(light: hLabelColor.primary, dark: hLabelColor.primary.inverted),
                backgroundColor: hTintColor.orangeTwo
            )
        case .none:
            EmptyView()
        }
    }
}
