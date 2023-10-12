import Foundation
import hGraphQL

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
        memberData: OctopusGraphQL.MemberDetailsQuery.Data.CurrentMember
    ) {
        self.id = memberData.id
        self.email = memberData.email
        self.phone = memberData.phoneNumber
        self.firstName = memberData.firstName
        self.lastName = memberData.lastName
    }

    public init(
        id: String,
        firstName: String,
        lastName: String,
        phone: String,
        email: String
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
    }
}
