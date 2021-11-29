import Foundation

public struct Claim: Codable, Equatable {
    public init(
        id: String,
        pills: [Claim.ClaimPill],
        segments: [Claim.ClaimStatusProgressSegment],
        title: String,
        subtitle: String
    ) {
        self.id = id
        self.pills = pills
        self.segments = segments
        self.title = title
        self.subtitle = subtitle
    }

    internal init(
        cardData: GraphQL.ClaimStatusCardsQuery.Data.ClaimsStatusCard
    ) {
        self.id = cardData.id
        self.pills = cardData.pills.map { .init(text: $0.text, type: .init(rawValue: $0.type.rawValue.lowercased()) ?? .none) }
        self.segments = cardData.progressSegments.map {
            .init(text: $0.text, type: .init(rawValue: $0.type.rawValue) ?? .none)
        }
        self.title = cardData.title
        self.subtitle = cardData.subtitle
    }

    public let id: String
    public let pills: [ClaimPill]
    public let segments: [ClaimStatusProgressSegment]
    public let title: String
    public let subtitle: String

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

public struct ClaimStatusCards {
    public let claims: [Claim]
    public init(
        cardData: GraphQL.ClaimStatusCardsQuery.Data
    ) {
        claims = cardData.claimsStatusCards.map { .init(cardData: $0) }
    }
}
