import Foundation

typealias ClaimStatusCard = GraphQL.ClaimStatusCardsQuery.Data.ClaimsStatusCard

public struct Claim: Codable, Equatable {
    public init(
        id: String,
        pills: [Claim.ClaimPill],
        segments: [Claim.ClaimStatusProgressSegment],
        title: String,
        subtitle: String,
        claimDetailData: ClaimDetailData
    ) {
        self.id = id
        self.pills = pills
        self.segments = segments
        self.title = title
        self.subtitle = subtitle
        self.claimDetailData = claimDetailData
    }

    internal init(
        cardData: GraphQL.ClaimStatusCardsQuery.Data.ClaimsStatusCard
    ) {
        self.id = cardData.id
        self.pills = cardData.pills.map {
            .init(text: $0.text, type: .init(rawValue: $0.type.rawValue.lowercased()) ?? .none)
        }
        self.segments = cardData.progressSegments.map {
            .init(text: $0.text, type: .init(rawValue: $0.type.rawValue) ?? .none)
        }
        self.title = cardData.title
        self.subtitle = cardData.subtitle

        self.claimDetailData = ClaimDetailData(claim: cardData.claim)
    }

    public let id: String
    public let pills: [ClaimPill]
    public let segments: [ClaimStatusProgressSegment]
    public let title: String
    public let subtitle: String
    public let claimDetailData: ClaimDetailData

    public struct ClaimDetailData: Codable, Equatable {
        internal init(
            id: String,
            status: Claim.ClaimDetailData.ClaimStatus,
            outcome: Claim.ClaimDetailData.ClaimOutcome,
            submittedAt: String?,
            closedAt: String?,
            signedAudioURL: String,
            progressSegments: [Claim.ClaimStatusProgressSegment],
            statusParagraph: String,
            type: String,
            payout: MonetaryAmount
        ) {
            self.id = id
            self.status = status
            self.outcome = outcome
            self.submittedAt = submittedAt
            self.closedAt = closedAt
            self.signedAudioURL = signedAudioURL
            self.progressSegments = progressSegments
            self.statusParagraph = statusParagraph
            self.type = type
            self.payout = payout
        }

        internal init(
            claim: ClaimStatusCard.Claim
        ) {
            self.id = claim.id
            self.status = .none
            self.outcome = .init(rawValue: claim.outcome?.rawValue ?? "") ?? .none
            self.submittedAt = claim.submittedAt
            self.closedAt = claim.closedAt
            self.signedAudioURL = claim.signedAudioUrl ?? ""
            self.progressSegments = claim.progressSegments.map {
                .init(text: $0.text, type: .init(rawValue: $0.type.rawValue) ?? .none)
            }
            self.statusParagraph = claim.statusParagraph
            self.type = claim.type ?? ""
            self.payout = .init(amount: claim.payout?.amount ?? "", currency: claim.payout?.currency ?? "")
        }

        public let id: String
        public let status: ClaimStatus
        public let outcome: ClaimOutcome
        public let submittedAt: String?
        public let closedAt: String?
        public let signedAudioURL: String
        public let progressSegments: [ClaimStatusProgressSegment]
        public let statusParagraph: String
        public let type: String
        public let payout: MonetaryAmount

        public enum ClaimStatus: String, Codable {
            case none
            case submitted
            case beingHandled
            case closed
            case reopened

            public init?(
                rawValue: RawValue
            ) {
                switch rawValue {
                case "SUBMITTED": self = .submitted
                case "BEING_HANDLED": self = .beingHandled
                case "CLOSED": self = .closed
                case "REOPENED": self = .reopened
                default: self = .none
                }
            }
        }

        public enum ClaimOutcome: String, Codable {
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
        }

    }

    public struct ClaimPill: Codable, Equatable {
        public init(
            text: String,
            type: Claim.ClaimPill.ClaimPillType
        ) {
            self.text = text
            self.type = type
        }

        public let text: String
        public let type: ClaimPillType

        public enum ClaimPillType: String, Codable {
            case none
            case open
            case reopened
            case closed
            case payment
        }
    }

    public struct ClaimStatusProgressSegment: Codable, Equatable {
        public init(
            text: String,
            type: Claim.ClaimStatusProgressSegment.ClaimStatusProgressType
        ) {
            self.text = text
            self.type = type
        }

        public let text: String
        public let type: ClaimStatusProgressType

        public enum ClaimStatusProgressType: String, Codable {
            case pastInactive
            case currentlyActive
            case futureInactive
            case paid
            case reopened
            case none

            public init?(
                rawValue: RawValue
            ) {
                switch rawValue {
                case "PAST_INACTIVE", "pastInactive": self = .pastInactive
                case "CURRENTLY_ACTIVE", "currentlyActive": self = .currentlyActive
                case "FUTURE_INACTIVE", "futureInactive": self = .futureInactive
                case "REOPENED", "reopened": self = .reopened
                case "PAID", "paid": self = .paid
                default: self = .none
                }
            }
        }
    }
}

public struct ClaimData {
    public let claims: [Claim]
    public init(
        cardData: GraphQL.ClaimStatusCardsQuery.Data
    ) {
        claims = cardData.claimsStatusCards.map { .init(cardData: $0) }
    }
}
