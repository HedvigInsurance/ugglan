import SwiftUI
import hCore
import hCoreUI

struct ClaimStatusCard: View {
    var claim: ClaimModel
    var enableTap: Bool

    @EnvironmentObject var homeRouter: NavigationRouter

    var body: some View {
        StatusCard(
            onSelected: nil,
            mainContent: ClaimPills(claim: claim),
            title: claim.claimType,
            subTitle: getSubTitle,
            bottomComponent: {
                VStack(spacing: .padding16) {
                    ClaimStatusBar(status: claim.status, outcome: claim.outcome)
                    if enableTap {
                        hButton(
                            .medium,
                            .secondary,
                            content: .init(title: L10n.ClaimStatus.ClaimDetails.button),
                            {
                                homeRouter.push(claim)
                            }
                        )
                        .hButtonTakeFullWidth(true)
                    }
                }
            }
        )
    }

    var getSubTitle: String? {
        guard let submittedAt = claim.submittedAt else { return nil }
        return L10n.ClaimStatus.ClaimDetails.submitted + " "
            + (submittedAt.localDateToIso8601Date?.displayDateMMMMDDYYYYFormat ?? "")
    }
}

struct ClaimPills: View {
    var claim: ClaimModel

    var body: some View {
        HStack {
            if let statusPill = statusPill {
                statusPill
            }
            if let outcomePill = outcomePill {
                outcomePill
            }
            if let payoutPill = payoutPill {
                payoutPill
            }
        }
        .hFieldSize(.small)
    }
}

extension ClaimPills {
    private var statusPill: hPill? {
        if claim.status == .reopened || (claim.status == .closed && claim.outcome != .paid) {
            return hPill(
                text: claim.status.title,
                color: claim.status.pillColor,
                colorLevel: .three
            )
        } else if claim.status != .closed {
            return hPill(
                text: L10n.Home.ClaimCard.Pill.claim,
                color: .grey,
                colorLevel: .two
            )
        }
        return nil
    }

    private var outcomePill: hPill? {
        if let outcome = claim.outcome {
            return hPill(
                text: outcome.text.capitalized,
                color: outcome.color,
                colorLevel: outcome.colorLevel
            )
        }
        return nil
    }

    private var payoutPill: hPill? {
        if let payout = claim.payoutAmount {
            return hPill(
                text: payout.formattedAmount,
                color: .blue,
                colorLevel: .two
            )
        }
        return nil
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

@MainActor
extension ClaimModel {
    static func previewData(
        id: String = "1",
        status: ClaimStatus = .closed,
        outcome: ClaimOutcome? = nil,
        submittedAt: String? = nil,
        payoutAmount: MonetaryAmount? = nil
    ) -> ClaimModel {
        ClaimModel(
            id: id,
            status: status,
            outcome: outcome,
            submittedAt: submittedAt,
            signedAudioURL: "",
            memberFreeText: nil,
            payoutAmount: payoutAmount,
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
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return hForm {
        hSection {
            VStack(spacing: .padding8) {
                ClaimStatusCard(claim: .previewData(status: .beingHandled), enableTap: true)
                ClaimStatusCard(claim: .previewData(status: .reopened), enableTap: true)
                ClaimStatusCard(
                    claim: .previewData(
                        status: .closed,
                        outcome: .paid,
                        payoutAmount: MonetaryAmount(amount: "100", currency: "SEK")
                    ),
                    enableTap: true
                )
                ClaimStatusCard(claim: .previewData(status: .closed, outcome: .notCompensated), enableTap: true)
                ClaimStatusCard(claim: .previewData(status: .closed, outcome: .notCovered), enableTap: true)
                ClaimStatusCard(claim: .previewData(status: .closed, outcome: .unresponsive), enableTap: true)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
