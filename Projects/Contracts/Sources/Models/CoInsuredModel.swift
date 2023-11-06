import Foundation
import hGraphQL

public struct CoInsuredModel: Codable, Hashable, Equatable {
    public let SSN: String?
    public let needsMissingInfo: Bool
    public var fullName: String?
    public var firstName: String?
    public var lastName: String?
    public var birthDate: String?
    
    public init(
        data: OctopusGraphQL.CoInsuredFragment
    ) {
        self.SSN = data.ssn
        self.birthDate = data.birthdate
        self.firstName = data.firstName
        self.lastName = data.lastName
        if let firstName, let lastName {
            self.fullName = firstName + " " + lastName
        }
        self.needsMissingInfo = data.needsMissingInfo
    }

    public init(
        fullName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        SSN: String? = nil,
        birthDate: String? = nil,
        needsMissingInfo: Bool
    ) {
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName
        if let firstName, let lastName {
            self.fullName = firstName + " " + lastName
        }
        self.birthDate = birthDate
        self.SSN = SSN
        self.needsMissingInfo = needsMissingInfo
    }
    
    var formattedSSN: String? {
        return SSN?.replacingOccurrences(of: "-", with: "")
    }
}

public struct CoInsureIntentdModel: Codable, Hashable, Equatable {
    let id: String
    let activationDate: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let state: String
}
