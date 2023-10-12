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
            signedAudioURL: String,
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
            self.statusParagraph = statusParagraph
            self.type = type
            self.subtitle = "subtitle"
        }

        internal init(
            claim: OctopusGraphQL.ClaimsQuery.Data.CurrentMember.Claim
        ) {
            self.id = claim.id
            self.status = ClaimStatus(rawValue: claim.status?.rawValue ?? "") ?? .none
            self.outcome = .init(rawValue: claim.outcome?.rawValue ?? "") ?? .none
            self.submittedAt = claim.submittedAt
            self.closedAt = claim.closedAt
            self.signedAudioURL = claim.audioUrl ?? ""
            self.statusParagraph = claim.memberFreeText ?? ""
            self.type = claim.associatedTypeOfContract ?? ""
            self.subtitle = claim.associatedTypeOfContract ?? ""
        }

        public let title = L10n.Claim.Casetype.insuranceCase
        public let subtitle: String
        public let id: String
        public let status: ClaimStatus
        public let outcome: ClaimOutcome
        public let submittedAt: String?
        public let closedAt: String?
        public let signedAudioURL: String
        public let statusParagraph: String
        public let type: String

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
                    return "Created"
                case .beingHandled:
                    return "In progress"
                case .closed:
                    return "Closed"
                case .none:
                    return "None"
                case .reopened:
                    return "Reopened"
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
                    return "Paid"
                case .notCompensated:
                    return "Not compensated"
                case .notCovered:
                    return "Not covered"
                case .none:
                    return "Claim"
                }
            }
        }

//    public struct ClaimPill: Codable, Equatable, Hashable {
//        public init(
//            text: String,
//            type: ClaimModel.ClaimPill.ClaimPillType
//        ) {
//            self.text = text
//            self.type = type
//        }
//
//        public let text: String
//        public let type: ClaimPillType
//
//        public enum ClaimPillType: String, Codable {
//            case none
//            case open
//            case reopened
//            case closed
//            case payment
//        }
//    }

//    public struct ClaimStatusProgressSegment: Codable, Equatable, Hashable {
//        public init(
//            text: String,
//            type: ClaimModel.ClaimStatusProgressSegment.ClaimStatusProgressType
//        ) {
//            self.text = text
//            self.type = type
//        }
//
//        public let text: String
//        public let type: ClaimStatusProgressType
//
//        public enum ClaimStatusProgressType: String, Codable {
////            case pastInactive
//            case currentlyActive
////            case futureInactive
////            case paid
//            case close
//            case reopened
//            case inProgress
//            case none
//
//            public init?(
//                rawValue: RawValue
//            ) {
//                switch rawValue {
////                case "PAST_INACTIVE", "pastInactive": self = .pastInactive
////                case "CURRENTLY_ACTIVE", "currentlyActive": self = .currentlyActive
////                case "FUTURE_INACTIVE", "futureInactive": self = .futureInactive
//                case "REOPENED", "reopened": self = .reopened
//                case "CREATED", "created": self = .currentlyActive
//                case "IN_PROGRESS", "in_progress": self = .inProgress
////                case "PAID", "paid": self = .paid
//                default: self = .none
//                }
//            }
//        }
//    }
}

//public struct ClaimData {
//    public let claims: [ClaimModel]
//    public init(
////        cardData: GiraffeGraphQL.ClaimStatusCardsQuery.Data
//        cardData: OctopusGraphQL.ClaimsQuery.Data
//    ) {
////        claims = cardData.map { .init(cardData: $0) }
//        claims = cardData.currentMember.claims.map({ .init(claim: $0 )})
//    }
//}
