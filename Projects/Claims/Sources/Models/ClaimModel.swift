import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct ClaimModel: Codable, Equatable, Identifiable, Hashable {

    public init(
        id: String,
        status: ClaimStatus,
        outcome: ClaimOutcome,
        submittedAt: String?,
        signedAudioURL: String?,
        memberFreeText: String?,
        payoutAmount: MonetaryAmount?,
        targetFileUploadUri: String,
        claimType: String,
        incidentDate: String?,
        productVariant: ProductVariant?
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
    }

    public let claimType: String
    public let incidentDate: String?
    public let productVariant: ProductVariant?
    public let id: String
    public let status: ClaimStatus
    public let outcome: ClaimOutcome
    public let submittedAt: String?
    public let signedAudioURL: String?
    public let memberFreeText: String?
    public let payoutAmount: MonetaryAmount?
    public let targetFileUploadUri: String
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
            case .none:
                return ""
            case .closed:
                return ""
            }
        case .reopened:
            return L10n.ClaimStatus.BeingHandledReopened.supportText
        default:
            return ""
        }
    }

    public enum ClaimStatus: String, Codable, CaseIterable {
        case none
        case submitted
        case beingHandled
        case closed
        case reopened

        public init?(
            rawValue: RawValue
        ) {
            switch rawValue {
            case "CREATED": self = .submitted
            case "IN_PROGRESS": self = .beingHandled
            case "CLOSED": self = .closed
            case "REOPENED": self = .reopened
            default: self = .none
            }
        }

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
    }

    public enum ClaimOutcome: String, Codable, CaseIterable {
        case paid
        case notCompensated
        case notCovered
        case none
        case closed

        public init?(
            rawValue: RawValue
        ) {
            switch rawValue {
            case "PAID": self = .paid
            case "NOT_COMPENSATED": self = .notCompensated
            case "NOT_COVERED": self = .notCovered
            case "CLOSED": self = .closed
            default: self = .none
            }
        }

        var text: String {
            switch self {
            case .paid:
                return L10n.Claim.Decision.paid
            case .notCompensated:
                return L10n.Claim.Decision.notCompensated
            case .notCovered:
                return L10n.Claim.Decision.notCovered
            case .none:
                return L10n.Home.ClaimCard.Pill.claim
            case .closed:
                return L10n.ClaimStatusDetail.closed
            }
        }
    }
}

extension ClaimModel: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: ClaimDetailView.self)
    }

}
