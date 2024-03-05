import Foundation

public class ProfileDemoService: ProfileService {
    
    public init() {}
    public func getProfileState() async throws -> (memberData: MemberDetails, partnerData: PartnerData?) {
        return (
            MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "", hasTravelCertificate: false), nil
        )
    }

    public func getMemberDetails() async throws -> MemberDetails {
        return MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "", hasTravelCertificate: false)
    }

    public func updateLanguage() async throws {
    }
}
