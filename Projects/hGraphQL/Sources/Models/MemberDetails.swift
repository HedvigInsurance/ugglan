import Foundation

public struct MemberDetails: Codable, Equatable, Identifiable {
    public var id: String
    public var phone: String?
    public var email: String?
    public var firstName: String
    public var lastName: String
    
    public var displayName: String {
        firstName + " " + lastName
    }
    
    public init?(
        memberData: GraphQL.MemberDetailsQuery.Data.Member
    ) {
        guard let id = memberData.id else { return nil }
        self.id = id.description
        self.email = memberData.email
        self.phone = memberData.phoneNumber
        self.firstName = memberData.firstName ?? ""
        self.lastName = memberData.lastName ?? ""
    }
}
