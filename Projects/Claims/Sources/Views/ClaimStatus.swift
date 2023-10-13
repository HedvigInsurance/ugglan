import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: ClaimModel
    var enableTap: Bool

    @PresentableStore
    var store: ClaimsStore

    var tapAction: (ClaimModel) -> Void {
        return { claim in
            store.send(.openClaimDetails(claim: claim))
        }
    }

    var body: some View {
        CardComponent(
            onSelected: enableTap ? {
                if enableTap {
                    tapAction(claim)
                } else {
                }
            } : nil,
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
            hColorScheme(light: hFillColor.opaqueTwo, dark: hGrayscaleColor.greyScale400)
        default:
            hTextColor.primary
        }
    }
}

struct ClaimBeingHandled_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .beingHandled,
            outcome: .none,
            submittedAt: "2023-10-10",
            closedAt: nil,
            signedAudioURL: "",
            type: "type",
            memberFreeText: nil
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}

struct ClaimReopened_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .reopened,
            outcome: .none,
            submittedAt: "2023-10-10",
            closedAt: nil,
            signedAudioURL: "",
            type: "type",
            memberFreeText: nil
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}

struct ClaimPaid_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .closed,
            outcome: .paid,
            submittedAt: "2023-10-10",
            closedAt: nil,
            signedAudioURL: "",
            type: "type",
            memberFreeText: nil
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}

struct ClaimNotCompensated_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .closed,
            outcome: .notCompensated,
            submittedAt: "2023-10-10",
            closedAt: nil,
            signedAudioURL: "",
            type: "type",
            memberFreeText: nil
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}

struct ClaimNotCocered_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .closed,
            outcome: .notCovered,
            submittedAt: "2023-10-10",
            closedAt: nil,
            signedAudioURL: "",
            type: "type",
            memberFreeText: nil
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}
