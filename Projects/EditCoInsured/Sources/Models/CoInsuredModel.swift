import Foundation
import hCore
import hGraphQL

public struct CoInsuredModel: Codable, Hashable, Equatable {
    public let SSN: String?
    public let hasMissingInfo: Bool
    public var firstName: String?
    public var lastName: String?
    public var birthDate: String?
    public let activatesOn: ServerBasedDate?
    public let terminatesOn: ServerBasedDate?
    public var fullName: String? {
        guard let firstName, let lastName else { return nil }
        return firstName + " " + lastName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: String {
        return (fullName ?? "") + (formattedSSN ?? "") + (birthDate ?? "")
    }

    public init(
        data: OctopusGraphQL.CoInsuredFragment
    ) {
        self.SSN = data.ssn
        self.birthDate = data.birthdate
        self.firstName = data.firstName
        self.lastName = data.lastName
        self.hasMissingInfo = data.hasMissingInfo
        self.activatesOn = data.activatesOn
        self.terminatesOn = data.terminatesOn
    }

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        SSN: String? = nil,
        birthDate: String? = nil,
        needsMissingInfo: Bool = true,
        activatesOn: String? = nil,
        terminatesOn: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.SSN = SSN?.calculate12DigitSSN
        self.hasMissingInfo = needsMissingInfo
        self.activatesOn = activatesOn
        self.terminatesOn = terminatesOn
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

extension String {
    // converts to a 12 digit personal number
    var calculate12DigitSSN: String {
        let formattedSSN = self.replacingOccurrences(of: "-", with: "")
        if formattedSSN.count == 10 {
            let ssnLastTwoDigitsOfYear = formattedSSN.prefix(2)
            let currentYear = Calendar.current.component(.year, from: Date())
            let firstTwoDigitsOfTheYear = currentYear / 100
            let lastTwoDigitsOfTheYear = currentYear % 100

            if let ssnLastTwoDigits = Int(ssnLastTwoDigitsOfYear),
                ssnLastTwoDigits > lastTwoDigitsOfTheYear
            {
                return String(firstTwoDigitsOfTheYear - 1) + self
            } else {
                return String(firstTwoDigitsOfTheYear) + self
            }
        } else {
            return self
        }
    }

    var calculate10DigitBirthDate: String {
        if let date = self.localDateToDate ?? self.localBirthDateStringToDate {
            return date.localDateString
        }
        return ""
    }

    var birtDateDisplayFormat: String {
        if let date = self.localDateToDate ?? self.localBirthDateStringToDate {
            return date.localBirthDateString
        }
        return ""
    }

    var displayFormatSSN: String? {
        let birthDate = self.prefix(8)
        let lastFourDigits = String(self.suffix(4))
        return birthDate + "-" + lastFourDigits
    }
}
