import Foundation

public class ProfileClientDemo: ProfileClient {
    public func update(eurobonus: String) async throws -> PartnerData {
        return PartnerData(sas: .init(eligible: false, eurobonusNumber: nil))
    }

    public init() {}
    public func getProfileState() async throws -> (memberData: MemberDetails, partnerData: PartnerData?) {
        return (
            MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "", hasTravelCertificate: false), nil
        )
    }

    public func getMemberDetails() async throws -> MemberDetails {
        return MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "", hasTravelCertificate: false)
    }

    public func updateLanguage() async throws {}

    public func postDeleteRequest() async throws {}

    public func update(email: String) async throws -> String { return email }
    public func update(phone: String) async throws -> String { return phone }
}
