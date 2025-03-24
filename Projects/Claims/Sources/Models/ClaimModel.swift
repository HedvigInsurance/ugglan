import Chat
import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct ClaimModel: Codable, Equatable, Identifiable, Hashable, Sendable {
    public init(
        id: String,
        status: ClaimStatus,
        outcome: ClaimOutcome?,
        submittedAt: String?,
        signedAudioURL: String?,
        memberFreeText: String?,
        payoutAmount: MonetaryAmount?,
        targetFileUploadUri: String,
        claimType: String,
        incidentDate: String?,
        productVariant: ProductVariant?,
        conversation: Conversation?,
        appealInstructionsUrl: String?,
        isUploadingFilesEnabled: Bool,
        showClaimClosedFlow: Bool
    ) {
        self.id = id
        self.status = status
        self.outcome = outcome
        self.submittedAt = submittedAt
        self.signedAudioURL = signedAudioURL
        self.memberFreeText = memberFreeText
        self.payoutAmount = payoutAmount
        self.targetFileUploadUri = targetFileUploadUri
        self.claimType = claimType
        self.incidentDate = incidentDate
        self.productVariant = productVariant
        self.conversation = conversation
        self.appealInstructionsUrl = appealInstructionsUrl
        self.isUploadingFilesEnabled = isUploadingFilesEnabled
        self.showClaimClosedFlow = showClaimClosedFlow
    }

    public let claimType: String
    public let incidentDate: String?
    public let productVariant: ProductVariant?
    public let id: String
    public let status: ClaimStatus
    public let outcome: ClaimOutcome?
    public let submittedAt: String?
    public let signedAudioURL: String?
    public let memberFreeText: String?
    public let payoutAmount: MonetaryAmount?
    public let targetFileUploadUri: String
    public let conversation: Conversation?
    public let appealInstructionsUrl: String?
    public let isUploadingFilesEnabled: Bool
    public let showClaimClosedFlow: Bool
    public var statusParagraph: String {
        switch self.status {
        case .submitted:
            return L10n.ClaimStatus.Submitted.supportText
        case .beingHandled:
            return L10n.ClaimStatus.BeingHandled.supportText
        case .closed:
            switch outcome {
            case .paid:
                return L10n.ClaimStatus.Paid.supportText
            case .notCompensated:
                return L10n.ClaimStatus.NotCompensated.supportText
            case .notCovered:
                return L10n.ClaimStatus.NotCovered.supportText
            case .unresponsive:
                return L10n.claimOutcomeUnresponsiveSupportText
            case .none:
                return ""
            }
        case .reopened:
            return L10n.ClaimStatus.BeingHandledReopened.supportText
        default:
            return ""
        }
    }

    public enum ClaimStatus: Codable, CaseIterable, Sendable {
        case none
        case submitted
        case beingHandled
        case closed
        case reopened

        var title: String {
            switch self {
            case .submitted:
                return L10n.Claim.StatusBar.submitted
            case .beingHandled:
                return L10n.Claim.StatusBar.beingHandled
            case .closed:
                return L10n.Claim.StatusBar.closed
            case .none:
                return ""
            case .reopened:
                return L10n.Home.ClaimCard.Pill.reopened
            }
        }

        var pillColor: PillColor {
            switch self {
            case .closed: .grey
            case .reopened: .amber
            default: .grey
            }
        }
    }

    public enum ClaimOutcome: Codable, CaseIterable, Sendable {
        case paid
        case notCompensated
        case notCovered
        case unresponsive

        var text: String {
            switch self {
            case .paid:
                return L10n.Claim.Decision.paid
            case .notCompensated:
                return L10n.Claim.Decision.notCompensated
            case .notCovered:
                return L10n.Claim.Decision.notCovered
            case .unresponsive:
                return L10n.Claim.Decision.unresponsive
            }
        }
    }
}

extension ClaimModel: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: ClaimDetailView.self)
    }
}
