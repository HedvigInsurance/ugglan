import Foundation

public struct PersonalData {
    public var firstName: String
    public var lastName: String
    public let fullname: String

    init(
        firstName: String,
        lastName: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.fullname = firstName + " " + lastName
    }
}
