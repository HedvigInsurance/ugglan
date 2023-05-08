import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: Claim

    @PresentableStore
    var store: ClaimsStore

    var body: some View {
        Button {
            store.send(.openClaimDetails(claim: claim))
        } label: {

        }
        .buttonStyle(ClaimStatusButtonStyle(claim: claim))
        .trackOnAppear(
            hAnalyticsEvent.claimCardVisible(
                claimId: self.claim.id,
                claimStatus: self.claim.claimDetailData.status.rawValue
            )
        )
        .trackOnTap(
            hAnalyticsEvent.claimCardClick(
                claimId: self.claim.id,
                claimStatus: self.claim.claimDetailData.status.rawValue
            )
        )
    }
}

struct ClaimStatusButtonStyle: ButtonStyle {
    let claim: Claim

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ClaimPills(claim: claim)
                Spacer()
                hCoreUIAssets.chevronRight.view
            }
            .padding([.leading, .trailing], 16)
            Spacer().frame(height: 20)
            hText(claim.title)
                .padding([.leading, .trailing], 16)
            Spacer().frame(height: 4)
            hText(claim.subtitle, style: .caption1)
                .foregroundColor(hLabelColor.secondary)
                .padding([.leading, .trailing], 16)
            Spacer().frame(height: 20)
            SwiftUI.Divider()
            Spacer().frame(height: 16)
            HStack(spacing: 6) {
                ForEach(claim.segments, id: \.text) { segment in
                    ClaimStatusBar(status: segment)
                }
            }
            .padding([.leading, .trailing], 16)
        }
        .padding([.top, .bottom], 16)
        .background(
            Squircle.default()
                .fill(hBackgroundColor.tertiary)
                .hShadow()
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
