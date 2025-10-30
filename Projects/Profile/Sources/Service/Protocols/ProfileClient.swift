import Foundation

@MainActor
public protocol ProfileClient {
    func getProfileState() async throws -> (
        memberData: MemberDetails, partnerData: PartnerData?, canCreateInsuranceEvidence: Bool,
        hasTravelInsurances: Bool
    )
    func getMemberDetails() async throws -> MemberDetails
    func updateLanguage() async throws
    func postDeleteRequest() async throws
    func update(email: String, phone: String) async throws -> (email: String, phone: String)
    func update(eurobonus: String) async throws -> PartnerData
    func updateSubscriptionPreference(to subscribed: Bool) async throws
}

public enum ProfileError: Error {
    case error(message: String)
}

extension ProfileError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .error(message): return message
        }
    }
}

public enum ChangeEuroBonusError: LocalizedError {
    case error(message: String)

    public var errorDescription: String? {
        switch self {
        case let .error(message):
            return message
        }
    }
}
