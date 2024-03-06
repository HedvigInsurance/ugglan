import Foundation

public protocol ProfileService {
    func getProfileState() async throws -> (memberData: MemberDetails, partnerData: PartnerData?)
    func getMemberDetails() async throws -> MemberDetails
    func updateLanguage() async throws
    func postDeleteRequest() async throws
    func update(email: String) async throws -> String
    func update(phone: String) async throws -> String
    func update(eurobonus: String) async throws -> PartnerData
}

enum ProfileError: Error {
    case error(message: String)
}

extension ProfileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .error(message): return message
        }
    }
}

enum ChangeEuroBonusError: LocalizedError {
    case error(message: String)

    public var errorDescription: String? {
        switch self {
        case let .error(message):
            return message
        }
    }
    var localizedDescription: String {
        switch self {
        case let .error(message):
            return message
        }
    }
}
