import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct ClaimStatusCard: View {
    var claimType: ClaimsStore.ActiveClaimType
    var enableTap: Bool
    @EnvironmentObject var homeRouter: NavigationRouter
    @State private var showDeleteConfirmation = false

    var body: some View {
        switch claimType {
        case let .claim(claim):
            StatusCard(
                onSelected: nil,
                mainContent: ClaimPills(claim: claim),
                title: claim.claimType,
                subTitle: claim.getSubTitle,
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
        case let .claimInProgress(model):
            StatusCard(
                onSelected: nil,
                mainContent: hPill(
                    text: L10n.resumeClaimDraft,
                    color: .amber,
                )
                .hFieldSize(.small),
                title: model.title ?? L10n.resumeClaimDefaultTitle,
                subTitle: model.createdAt.getSubTitle,
                bottomComponent: {
                    VStack(spacing: .padding16) {
                        HStack(alignment: .top, spacing: .padding6) {
                            VStack {
                                Rectangle()
                                    .fill(hFillColor.Opaque.disabled)
                                    .frame(height: 4)
                                    .cornerRadius(.cornerRadiusXS)
                                hText(L10n.Claim.StatusBar.submitted, style: .label)
                                    .foregroundColor(hFillColor.Opaque.disabled)
                            }
                            .frame(maxWidth: .infinity)
                            VStack {
                                Rectangle()
                                    .fill(hFillColor.Opaque.disabled)
                                    .frame(height: 4)
                                    .cornerRadius(.cornerRadiusXS)
                                hText(L10n.Claim.StatusBar.beingHandled, style: .label)
                                    .foregroundColor(hFillColor.Opaque.disabled)
                            }
                            .frame(maxWidth: .infinity)

                            VStack {
                                Rectangle()
                                    .fill(hFillColor.Opaque.disabled)
                                    .frame(height: 4)
                                    .cornerRadius(.cornerRadiusXS)
                                hText(L10n.Claim.StatusBar.closed, style: .label)
                                    .foregroundColor(hFillColor.Opaque.disabled)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        HStack(spacing: .padding8) {
                            hButton(.medium, .secondary, content: .init(title: L10n.resumeClaimDeleteButton)) {
                                showDeleteConfirmation = true
                            }
                            hButton(.medium, .primary, content: .init(title: L10n.resumeClaimContinueButton)) {
                                NotificationCenter.default.post(
                                    name: .startClaim,
                                    object: StartClaimInputType.inProgress
                                )
                            }
                        }
                        .hButtonTakeFullWidth(true)
                    }
                }
            )
            .alert(
                L10n.resumeClaimDeleteTitle,
                isPresented: $showDeleteConfirmation
            ) {
                Button(L10n.generalCancelButton, role: .cancel) {}
                Button(L10n.resumeClaimDeleteButton, role: .destructive) {
                    let store: ClaimsStore = globalAppStateContainer.get()
                    Task { await store.deleteClaimInProgress() }
                }
            } message: {
                Text(L10n.resumeClaimDeleteBody)
            }
        }
    }
}

@MainActor
extension ClaimModel {
    fileprivate var getSubTitle: String? {
        guard let formatted = self.submittedAt?.displayDateDDMMMYYYYFormat else { return nil }
        return L10n.ClaimStatus.ClaimDetails.submitted + " " + formatted
    }
}

@MainActor
extension Date {
    fileprivate var getSubTitle: String {
        let formatted = self.displayDateDDMMMYYYYFormat
        return L10n.resumeClaimStated(formatted)
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
        if claim.isPartnerClaim {
            if claim.status == .closed {
                return hPill(
                    text: L10n.Claim.StatusBar.closed,
                    color: .grey,
                    colorLevel: .three
                )
            }
            return hPill(
                text: L10n.Home.ClaimCard.Pill.claim,
                color: .grey,
                colorLevel: .two
            )
        }
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
        if claim.isPartnerClaim { return nil }
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
        submittedAt: Date? = nil,
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
                createdAt: Date(),
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
                ClaimStatusCard(
                    claimType: .claim(model: .previewData(status: .beingHandled)),
                    enableTap: true
                )
                ClaimStatusCard(
                    claimType: .claim(model: .previewData(status: .reopened)),
                    enableTap: true
                )
                ClaimStatusCard(
                    claimType: .claim(
                        model: .previewData(
                            status: .closed,
                            outcome: .paid,
                            payoutAmount: MonetaryAmount(amount: "100", currency: "SEK")
                        )
                    ),
                    enableTap: true
                )
                ClaimStatusCard(
                    claimType: .claim(model: .previewData(status: .closed, outcome: .notCompensated)),
                    enableTap: true
                )
                ClaimStatusCard(
                    claimType: .claim(model: .previewData(status: .closed, outcome: .notCovered)),
                    enableTap: true
                )
                ClaimStatusCard(
                    claimType: .claim(model: .previewData(status: .closed, outcome: .unresponsive)),
                    enableTap: true
                )
                ClaimStatusCard(
                    claimType: .claimInProgress(model: .init(id: "1", createdAt: Date(), title: "TITLE")),
                    enableTap: true
                )
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
