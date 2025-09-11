import Foundation

public struct PersonalData: Sendable {
    public var firstName: String
    public var lastName: String
    public let fullname: String

    public init(
        firstName: String,
        lastName: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        fullname = firstName + " " + lastName
    }
}
