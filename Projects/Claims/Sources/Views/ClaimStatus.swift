import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: ClaimModel
    
    @PresentableStore
    var store: ClaimsStore
    
    var tapAction: (ClaimModel) -> Void {
        return { claim in
            store.send(.openClaimDetails(claim: claim))
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
                    ClaimStatusBar(status: claim.status, outcome: claim.outcome)
                }
            }
        )
    }
}

struct ClaimPills: View {
    var claim: ClaimModel
    
    var body: some View {
        HStack {
            if claim.status == .reopened {
                hPillFill(
                    text: claim.status.title,
                    textColor: hSignalColor.amberText,
                    backgroundColor: hSignalColor.amberHighLight
                )
            }
            hPillFill(
                text: claim.outcome.text.capitalized,
                textColor: claim.outcome.textColor,
                backgroundColor: claim.outcome.backgroundColor
            )
        }
    }
}

extension ClaimModel.ClaimOutcome {
    @hColorBuilder
    var textColor: some hColor {
        switch self {
        case .paid:
            hTextColor.negative
        default:
            hColorScheme(light: hTextColor.primary, dark: hTextColor.negative)
        }
    }
    
    @hColorBuilder
    var backgroundColor: some hColor {
        switch self {
        case .none:
            hColorScheme(light:  hFillColor.opaqueTwo, dark: hGrayscaleColor.greyScale400)
        default:
            hTextColor.primary
        }
    }
}

struct ClaimStatus_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .reopened,
            outcome: .notCompensated,
            submittedAt: "2023-010-10",
            closedAt: nil,
            signedAudioURL: "",
            statusParagraph: "",
            type: "type"
         )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}
