import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    @State var claim: Claim

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ClaimPills(claim: claim)
                Spacer()
                //Image(uiImage: hCoreUIAssets.chevronRight.image).tint(hLabelColor.secondary)
            }
            .padding([.leading, .trailing], 10)
            Spacer().frame(height: 23)
            hText(L10n.Claim.Casetype.newInsuranceCase)
                .padding([.leading, .trailing], 10)
            Spacer().frame(height: 20)
            SwiftUI.Divider()
            Spacer().frame(height: 16)
            HStack {
                ClaimStatusBar(status: .submitted, currentStatus: claim.status)
                ClaimStatusBar(status: .beingHandled, currentStatus: claim.status)
                ClaimStatusBar(status: .closed, currentStatus: claim.status)
            }
            .padding([.leading, .trailing], 10)
        }
        .padding([.top, .bottom], 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(hBackgroundColor.tertiary)
                .shadow(radius: 4)
        )
    }
}

struct ClaimPills: View {
    @State var claim: Claim

    var body: some View {
        HStack {
            claim.status.pill
            claim.outcome.pill
        }
    }
}

extension Claim.ClaimStatus {
    var text: String? {
        switch self {
        case .none:
            return nil
        case .submitted:
            return L10n.Claim.StatusBar.submitted
        case .beingHandled:
            return L10n.Claim.StatusBar.beingHandled
        case .closed:
            return L10n.Claim.StatusBar.closed
        case .reopened:
            return nil
        }
    }
}

extension Claim.ClaimOutcome {
    @ViewBuilder
    var pill: some View {
        switch self {
        case .paid:
            hPillFill(text: L10n.Claim.Decision.paid.uppercased(), backgroundColor: hBackgroundColor.primary)
                .invertColorScheme
        case .notCompensated:
            hPillFill(
                text: L10n.Claim.Decision.notCompensated.uppercased(),
                backgroundColor: hBackgroundColor.primary.inverted
            )
            .invertColorScheme
        case .notCovered:
            hPillFill(
                text: L10n.Claim.Decision.notCovered.uppercased(),
                backgroundColor: hBackgroundColor.primary.inverted
            )
            .invertColorScheme
        case .none:
            EmptyView()
        }
    }
}

extension Claim.ClaimStatus {
    @ViewBuilder
    var pill: some View {
        if self == .beingHandled || self == .submitted {
            hPillOutline(text: L10n.Home.ClaimCard.Pill.claim.uppercased())
        } else if self == .reopened {
            hPillFill(text: L10n.Home.ClaimCard.Pill.reopened.uppercased(), backgroundColor: hTintColor.orangeTwo)
        } else {
            EmptyView()
        }
    }
}

extension Claim {
    public static var mock = Claim(
        id: "1234",
        status: .reopened,
        outcome: .paid,
        submittedAt: "",
        closedAt: "",
        signedAudioURL: nil
    )
}

struct ClaimsPreview: PreviewProvider {
    static var previews: some View {
        ClaimStatus(claim: .mock).preferredColorScheme(.light).previewAsComponent()
    }
}
