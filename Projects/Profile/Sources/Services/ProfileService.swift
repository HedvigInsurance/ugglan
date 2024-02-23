import Foundation

public protocol ProfileService {
    func getProfileState() async throws -> (memberData: MemberDetails, partnerData: PartnerData?)
    func getMemberDetails() async throws -> MemberDetails?
    func updateLanguage() async throws
}
