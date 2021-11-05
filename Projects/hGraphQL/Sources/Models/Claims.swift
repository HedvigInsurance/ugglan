import Foundation

public struct Claim: Codable, Equatable {
    #if DEBUG
    public init(id: String, status: Claim.ClaimStatus, outcome: Claim.ClaimOutcome, submittedAt: String, closedAt: String?, signedAudioURL: String?) {
        self.id = id
        self.status = status
        self.outcome = outcome
        self.submittedAt = submittedAt
        self.closedAt = closedAt
        self.signedAudioURL = signedAudioURL
    }
    #endif
    
    public let id: String
    public let status: ClaimStatus
    public let outcome: ClaimOutcome
    public let submittedAt: String
    public let closedAt: String?
    public let signedAudioURL: String?
    
    public init(claim: GraphQL.ClaimsQuery.Data.Claim) {
        self.id = claim.id
        self.status = .init(rawValue: claim.status.rawValue) ?? .none
        self.outcome = .init(rawValue: claim.outcome?.rawValue ?? "") ?? .none
        self.submittedAt = claim.submittedAt
        self.closedAt = claim.closedAt
        self.signedAudioURL = claim.signedAudioUrl
    }
    
    public enum ClaimStatus: String, Codable {
        case none
        case submitted
        case beingHandled
        case closed
        case reopened
        
        public init?(rawValue: RawValue) {
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
        
        public init?(rawValue: RawValue) {
          switch rawValue {
            case "PAID": self = .paid
            case "NOT_COMPENSATED": self = .notCompensated
            case "NOT_COVERED": self = .notCovered
            default: self = .none
          }
        }
    }
}
