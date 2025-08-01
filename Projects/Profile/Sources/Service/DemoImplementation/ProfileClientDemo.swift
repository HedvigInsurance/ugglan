import Foundation

public class ProfileClientDemo: ProfileClient {
    public func update(eurobonus _: String) async throws -> PartnerData {
        PartnerData(sas: .init(eligible: false, eurobonusNumber: nil))
    }

    public init() {}
    public func getProfileState() async throws -> (
        memberData: MemberDetails, partnerData: PartnerData?, canCreateInsuranceEvidence: Bool,
        hasTravelInsurances: Bool
    ) {
        (
            MemberDetails(
                id: "",
                firstName: "",
                lastName: "",
                phone: "",
                email: "",
                hasTravelCertificate: false,
                isContactInfoUpdateNeeded: true
            ), nil,
            false,
            false
        )
    }

    public func getMemberDetails() async throws -> MemberDetails {
        MemberDetails(
            id: "",
            firstName: "",
            lastName: "",
            phone: "",
            email: "",
            hasTravelCertificate: false,
            isContactInfoUpdateNeeded: true
        )
    }

    public func updateLanguage() async throws {}

    public func postDeleteRequest() async throws {}

    public func update(email: String, phone: String) async throws -> (email: String, phone: String) {
        (email, phone)
    }

    public func updateSubscriptionPreference(to _: Bool) async throws {}
}
