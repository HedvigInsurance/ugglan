import Foundation

public struct CoInsuredModel: Codable, Hashable, Equatable {
    let firstName: String?
    let lastName: String?
    let SSN: String?
    var fullName: String {
        return firstName ?? "" + " " + (lastName ?? "")
    }

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        SSN: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.SSN = SSN
    }
}
