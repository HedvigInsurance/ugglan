import SwiftUI
import hCore
import hCoreUI

struct ClaimStatus: View {
    var claim: ClaimModel
    var enableTap: Bool

    init(
        claim: ClaimModel,
        enableTap: Bool
    ) {
        self.claim = claim
        self.enableTap = enableTap
    }

    @EnvironmentObject var homeRouter: Router
    var tapAction: (ClaimModel) -> Void {
        return { claim in
            homeRouter.push(claim)
        }
    }

    var body: some View {
        StatusCard(
            onSelected: nil,
            mainContent: ClaimPills(claim: claim),
            title: claim.claimType,
            subTitle: getSubTitle,
            bottomComponent: {
                VStack(spacing: .padding16) {
                    HStack(spacing: .padding6) {
                        ClaimStatusBar(status: claim.status, outcome: claim.outcome)
                    }
                    if enableTap {
                        hButton.MediumButton(
                            type: .secondary
                        ) {
                            tapAction(claim)
                        } content: {
                            hText(L10n.ClaimStatus.ClaimDetails.button)
                        }
                        .hButtonTakeFullWidth(true)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        )
    }

    var getSubTitle: String? {
        if let submittedAt = claim.submittedAt {
            return L10n.ClaimStatus.ClaimDetails.submitted + " "
                + (submittedAt.localDateToIso8601Date?.displayDateMMMMDDYYYYFormat ?? "")
        }
        return nil
    }
}

struct ClaimPills: View {
    var claim: ClaimModel

    var body: some View {
        HStack {
            if claim.status == .reopened || (claim.status == .closed && claim.outcome != .paid) {
                hPill(
                    text: claim.status.title,
                    color: claim.status.pillColor,
                    colorLevel: .three
                )
            } else if claim.status != .closed {
                hPill(
                    text: L10n.Home.ClaimCard.Pill.claim,
                    color: .grey,
                    colorLevel: .two
                )
            }
            if let outcome = claim.outcome {
                hPill(
                    text: outcome.text.capitalized,
                    color: outcome.color,
                    colorLevel: outcome.colorLevel
                )
            }

            if let payout = claim.payoutAmount {
                hPill(
                    text: payout.formattedAmount,
                    color: .blue,
                    colorLevel: .two
                )
            }
        }
        .hFieldSize(.small)
    }
}

extension ClaimModel.ClaimOutcome {
    var color: PillColor {
        switch self {
        case .notCompensated, .notCovered, .paid, .unresponsive:
            .grey
        }
    }

    var colorLevel: PillColor.PillColorLevel {
        switch self {
        case .notCompensated, .notCovered, .unresponsive:
            .two
        case .paid:
            .three
        }
    }
}

struct ClaimBeingHandled_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        let data = ClaimModel(
            id: "1",
            status: .beingHandled,
            outcome: nil,
            submittedAt: "2023-06-10",
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            productVariant: nil,
            conversation: .init(
                id: "",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            ),
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text",
            displayItems: []
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)

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
            productVariant: nil,
            conversation: .init(
                id: "",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            ),
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text",
            displayItems: []
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)

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
            productVariant: nil,
            conversation: .init(
                id: "",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            ),
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text",
            displayItems: []
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)
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
            productVariant: nil,
            conversation: .init(
                id: "",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            ),
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text",
            displayItems: []
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)

        }
        .padding(20)
    }
}

struct ClaimNotCovered_Previews: PreviewProvider {
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
            productVariant: nil,
            conversation: .init(
                id: "",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            ),
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text",
            displayItems: []
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)

        }
        .padding(20)
    }
}

struct ClaimNoResponse_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .closed,
            outcome: .unresponsive,
            submittedAt: "2023-10-10",
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            productVariant: nil,
            conversation: .init(
                id: "",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            ),
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: nil,
            displayItems: []
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)

        }
        .padding(20)
    }
}

struct ClaimClosed_Previews: PreviewProvider {
    static var previews: some View {
        let data = ClaimModel(
            id: "1",
            status: .closed,
            outcome: .paid,
            submittedAt: "2023-10-10",
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            productVariant: nil,
            conversation: .init(
                id: "convId",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            ),
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text",
            displayItems: []
        )
        return VStack(spacing: 20) {
            ClaimStatus(claim: data, enableTap: true)

        }
        .padding(20)
    }
}
