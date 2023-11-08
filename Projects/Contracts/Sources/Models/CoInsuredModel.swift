import Foundation

public struct CoInsuredModel: Codable, Hashable, Equatable {
    let id: String
    let firstName: String?
    let lastName: String?
    let SSN: String?
    var fullName: String? {
        guard let firstName, let lastName else { return nil }
        return firstName + " " + lastName
    }

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        SSN: String? = nil
    ) {
        self.id = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
        self.SSN = SSN
    }

    public var hasMissingData: Bool {
        return fullName == nil
    }
}
