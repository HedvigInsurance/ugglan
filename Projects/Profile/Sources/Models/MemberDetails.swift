import Foundation
import hGraphQL

public struct MemberDetails: Codable, Equatable, Identifiable, Hashable {
    public var id: String
    public var phone: String?
    public var email: String?
    public var firstName: String
    public var lastName: String
    let hasTravelCertificate: Bool

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
        self.hasTravelCertificate = false
    }

    public init(
        id: String,
        firstName: String,
        lastName: String,
        phone: String,
        email: String,
        hasTravelCertificate: Bool
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.hasTravelCertificate = hasTravelCertificate
    }
}
