import Foundation
import hGraphQL

public struct CoInsuredModel: Codable, Hashable, Equatable {
    public let SSN: String?
    public let needsMissingInfo: Bool
    public var firstName: String?
    public var lastName: String?
    public var birthDate: String?
    var fullName: String? {
        guard let firstName, let lastName else { return nil }
        return firstName + " " + lastName
    }

    var id: String {
        return fullName ?? "" + (formattedSSN ?? "") + (birthDate ?? "")
    }

    public init(
        data: OctopusGraphQL.CoInsuredFragment
    ) {
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

    public static func == (lhs: CoInsuredModel, rhs: CoInsuredModel) -> Bool {
        return lhs.fullName == rhs.fullName
            && (lhs.formattedSSN == rhs.formattedSSN
                || lhs.birthDate == rhs.birthDate)
    }
}

public struct CoInsureIntentdModel: Codable, Hashable, Equatable {
    let id: String
    let activationDate: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let state: String
}
