import Foundation
import hGraphQL

public struct MemberDetails: Codable, Equatable, Identifiable, Hashable, Sendable {
    public var id: String
    public var phone: String?
    public var email: String?
    public var firstName: String
    public var lastName: String
    let isTravelCertificateEnabled: Bool

    public var displayName: String {
        firstName + " " + lastName
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
        self.isTravelCertificateEnabled = hasTravelCertificate
    }
}
