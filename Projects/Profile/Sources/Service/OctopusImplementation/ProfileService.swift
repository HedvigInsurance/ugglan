import Foundation
import hCore

@MainActor
class ProfileService {
    @Inject var client: ProfileClient

    public func getProfileState() async throws -> (
        memberData: MemberDetails, partnerData: PartnerData?, canCreateInsuranceEvidence: Bool,
        hasTravelInsurances: Bool
    ) {
        log.info("ProfileService: getProfileState", error: nil, attributes: nil)
        return try await client.getProfileState()
    }

    public func getMemberDetails() async throws -> MemberDetails {
        log.info("ProfileService: getMemberDetails", error: nil, attributes: nil)
        return try await client.getMemberDetails()
    }

    public func postDeleteRequest() async throws {
        log.info("ProfileService: postDeleteRequest", error: nil, attributes: nil)
        return try await client.postDeleteRequest()
    }

    public func updateLanguage() async throws {
        log.info("ProfileService: updateLanguage", error: nil, attributes: nil)
        return try await client.updateLanguage()
    }

    public func update(email: String?, phone: String?) async throws -> (email: String, phone: String) {
        log.info("ProfileService: update", error: nil, attributes: nil)
        return try await client.update(email: email ?? "", phone: phone ?? "")
    }

    func update(eurobonus: String) async throws -> PartnerData {
        log.info("ProfileService: update(eurobonus)", error: nil, attributes: nil)
        return try await client.update(eurobonus: eurobonus)
    }

    func updateSubscriptionPreference(to subscribed: Bool) async throws {
        log.info("ProfileService: updateSubscriptionPreference", error: nil, attributes: nil)
        return try await client.updateSubscriptionPreference(to: subscribed)
    }
}
