import Foundation
import hCore

@MainActor
public class ProfileService {
    @Inject var client: ProfileClient

    public func getProfileState() async throws -> (memberData: MemberDetails, partnerData: PartnerData?) {
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

    func update(email: String) async throws -> String {
        log.info("ProfileService: update(email)", error: nil, attributes: nil)
        return try await client.update(email: email)
    }

    func update(phone: String) async throws -> String {
        log.info("ProfileService: update(phone)", error: nil, attributes: nil)
        return try await client.update(phone: phone)
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
