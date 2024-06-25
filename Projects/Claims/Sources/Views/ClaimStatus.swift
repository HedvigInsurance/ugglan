import Home
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: ClaimModel
    var enableTap: Bool

    @EnvironmentObject var homeRouter: Router

    @PresentableStore
    var store: ClaimsStore

    var tapAction: (ClaimModel) -> Void {
        return { claim in
            homeRouter.push(claim)
        }
    }

    var body: some View {
        CardComponent(
            onSelected: enableTap
                ? {
                    if enableTap {
                        tapAction(claim)
                    } else {
                    }
                } : nil,
            mainContent: ClaimPills(claim: claim),
            title: claim.claimType,
            subTitle: getSubTitle,
            bottomComponent: {
                HStack(spacing: 6) {
                    ClaimStatusBar(status: claim.status, outcome: claim.outcome)
                }
            }
        )
    }

    var getSubTitle: String? {
        if let submittedAt = claim.submittedAt {
            return L10n.ClaimStatus.ClaimDetails.submitted + " "
                + (submittedAt.localDateToDate?.displayDateMMMMDDYYYYFormat ?? "")
        }
        return nil
    }
}

struct ClaimPills: View {
    var claim: ClaimModel

    var body: some View {
        HStack {
            if claim.status == .reopened {
                hPillFill(
                    text: claim.status.title,
                    textColor: hSignalColor.Amber.text,
                    backgroundColor: hSignalColor.Amber.highLight
                )
            }
            hPillFill(
                text: claim.outcome.text.capitalized,
                textColor: claim.outcome.textColor,
                backgroundColor: claim.outcome.backgroundColor
            )
            if let payout = claim.payoutAmount {
                hPillFill(
                    text: payout.formattedAmount,
                    textColor: hSignalColor.Blue.text,
                    backgroundColor: hSignalColor.Blue.highLight
                )
            }
        }
    }
}

extension ClaimModel.ClaimOutcome {
    @hColorBuilder
    var textColor: some hColor {
        switch self {
        case .paid, .closed:
            hTextColor.Opaque.negative
        case .none, .notCompensated, .notCovered:
            hTextColor.Opaque.primary
        }
    }

    @hColorBuilder
    var backgroundColor: some hColor {
        switch self {
        case .none, .notCompensated, .notCovered:
            hSurfaceColor.Translucent.secondary
        case .paid, .closed:
            hBackgroundColor.negative
        }
    }
}

struct ClaimBeingHandled_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .beingHandled,
            outcome: .none,
            submittedAt: "2023-06-10",
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            incidentDate: "2024-02-15",
            productVariant: nil
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
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            incidentDate: "2024-02-15",
            productVariant: nil
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
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: MonetaryAmount(amount: "100", currency: "SEK"),
            targetFileUploadUri: "",
            claimType: "Broken item",
            incidentDate: "2024-02-15",
            productVariant: nil
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
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            incidentDate: "2024-02-15",
            productVariant: nil
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
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            incidentDate: "2024-02-15",
            productVariant: nil
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}
