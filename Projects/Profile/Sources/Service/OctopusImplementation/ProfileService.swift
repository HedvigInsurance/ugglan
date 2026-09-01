import AutomaticLog
import Foundation
import hCore

@MainActor
class ProfileService {
    @Inject var client: ProfileClient

    @Log
    func getProfileState() async throws -> (
        memberData: MemberDetails, partnerData: PartnerData?, canCreateInsuranceEvidence: Bool,
        hasTravelInsurances: Bool
    ) {
        try await client.getProfileState()
    }

    @Log
    func getMemberDetails() async throws -> MemberDetails {
        try await client.getMemberDetails()
    }

    @Log
    func postDeleteRequest() async throws {
        try await client.postDeleteRequest()
    }

    @Log
    func updateLanguage() async throws {
        try await client.updateLanguage()
    }

    // The result tuple echoes the same contact details back and cannot be annotated,
    // so the output is not logged.
    @Log(.error, sensitive: ["email", "phone"])
    func update(email: String?, phone: String?) async throws -> (email: String, phone: String) {
        try await client.update(email: email ?? "", phone: phone ?? "")
    }

    @Log(sensitive: ["eurobonus"])
    func update(eurobonus: String) async throws -> PartnerData {
        try await client.update(eurobonus: eurobonus)
    }

    @Log
    func updateSubscriptionPreference(to subscribed: Bool) async throws {
        try await client.updateSubscriptionPreference(to: subscribed)
    }
}
