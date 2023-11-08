import Foundation
import hGraphQL

public struct CoInsuredModel: Codable, Hashable, Equatable {
    let id: String
    public let SSN: String?
    public let needsMissingInfo: Bool
    public var firstName: String?
    public var lastName: String?
    public var birthDate: String?
    var fullName: String? {
        guard let firstName, let lastName else { return nil }
        return firstName + " " + lastName
    }

    public init(
        data: OctopusGraphQL.CoInsuredFragment
    ) {
        self.id = UUID().uuidString
        self.SSN = data.ssn
        self.birthDate = data.birthdate
        self.firstName = data.firstName
        self.lastName = data.lastName
        self.needsMissingInfo = data.needsMissingInfo
    }

    public init(
        fullName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        SSN: String? = nil,
        birthDate: String? = nil,
        needsMissingInfo: Bool = true
    ) {
        self.id = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.SSN = SSN
        self.needsMissingInfo = needsMissingInfo
    }

    var formattedSSN: String? {
        return SSN?.replacingOccurrences(of: "-", with: "")
    }

    public var hasMissingData: Bool {
        return fullName == nil
    }
}

public struct CoInsureIntentdModel: Codable, Hashable, Equatable {
    let id: String
    let activationDate: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let state: String
}
