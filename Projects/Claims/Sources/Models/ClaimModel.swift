import Foundation
import hCore
import hGraphQL

public struct ClaimModel: Codable, Equatable, Identifiable, Hashable {

    public init(
        id: String,
        status: ClaimStatus,
        outcome: ClaimOutcome,
        submittedAt: String?,
        closedAt: String?,
        signedAudioURL: String?,
        type: String,
        memberFreeText: String?,
        payoutAmount: MonetaryAmount?,
        files: [File]
    ) {
        self.id = id
        self.status = status
        self.outcome = outcome
        self.submittedAt = submittedAt
        self.closedAt = closedAt
        self.signedAudioURL = signedAudioURL
        self.type = type
        self.subtitle = ""
        self.memberFreeText = memberFreeText
        self.payoutAmount = payoutAmount
        self.files = files
    }

    public var title: String {
        L10n.Claim.Casetype.insuranceCase
    }
    public let subtitle: String
    public let id: String
    public let status: ClaimStatus
    public let outcome: ClaimOutcome
    public let submittedAt: String?
    public let closedAt: String?
    public let signedAudioURL: String?
    public let memberFreeText: String?
    public let payoutAmount: MonetaryAmount?
    public let type: String
    public let files: [File]

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
            }
        case .reopened:
            return L10n.ClaimStatus.BeingHandledReopened.supportText
        default:
            return ""
        }
    }

    public var showUploadedFiles: Bool {
        return self.signedAudioURL != nil || !files.isEmpty || canAddFiles
    }

    public var canAddFiles: Bool {
        return self.status != .closed
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

        public init?(
            rawValue: RawValue
        ) {
            switch rawValue {
            case "PAID": self = .paid
            case "NOT_COMPENSATED": self = .notCompensated
            case "NOT_COVERED": self = .notCovered
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
            }
        }
    }
}
