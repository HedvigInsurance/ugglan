import Foundation
import SwiftUI
import hGraphQL

public struct InsuredPeopleConfig: Codable & Equatable & Hashable {
    public var contractCoInsured: [CoInsuredModel]
    public var contractId: String
    public var activeFrom: String?
    public var numberOfMissingCoInsured: Int
    public var numberOfMissingCoInsuredWithoutTermination: Int
    public let displayName: String
    public let preSelectedCoInsuredList: [CoInsuredModel]
    public let contractDisplayName: String
    public let holderFirstName: String
    public let holderLastName: String
    public let holderSSN: String?
    public var holderFullName: String {
        return holderFirstName + " " + holderLastName
    }

    public init() {
        self.contractCoInsured = []
        self.contractId = ""
        self.activeFrom = nil
        self.numberOfMissingCoInsured = 0
        self.numberOfMissingCoInsuredWithoutTermination = 0
        self.displayName = ""
        self.holderFirstName = ""
        self.holderLastName = ""
        self.holderSSN = nil
        self.preSelectedCoInsuredList = []
        self.contractDisplayName = ""
    }

    public init(
        contractCoInsured: [CoInsuredModel],
        contractId: String,
        activeFrom: String?,
        numberOfMissingCoInsured: Int,
        numberOfMissingCoInsuredWithoutTermination: Int,
        displayName: String,
        preSelectedCoInsuredList: [CoInsuredModel],
        contractDisplayName: String,
        holderFirstName: String,
        holderLastName: String,
        holderSSN: String?
    ) {
        self.contractCoInsured = contractCoInsured
        self.contractId = contractId
        self.activeFrom = activeFrom
        self.numberOfMissingCoInsured = numberOfMissingCoInsured
        self.numberOfMissingCoInsuredWithoutTermination = numberOfMissingCoInsuredWithoutTermination
        self.displayName = displayName
        self.preSelectedCoInsuredList = preSelectedCoInsuredList
        self.contractDisplayName = contractDisplayName
        self.holderFirstName = holderFirstName
        self.holderLastName = holderLastName
        self.holderSSN = holderSSN
    }
}

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

    public var formattedSSN: String? {
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

public enum StatusPillType {
    case added
    case deleted

    public func text(date: String) -> String {
        switch self {
        case .added:
            return L10n.contractAddCoinsuredActiveFrom(date)
        case .deleted:
            return L10n.contractAddCoinsuredActiveUntil(date)
        }
    }
}

public struct CoInsuredListType: Hashable, Identifiable {
    public let id = UUID().uuidString
    public init(
        coInsured: CoInsuredModel,
        type: StatusPillType? = nil,
        date: String? = nil,
        locallyAdded: Bool,
        isContractOwner: Bool? = nil,
        isEmpty: Bool? = false
    ) {
        self.coInsured = coInsured
        self.type = type
        self.date = date
        self.locallyAdded = locallyAdded
        self.isContractOwner = isContractOwner
        self.isEmpty = isEmpty
    }

    public var coInsured: CoInsuredModel
    public var type: StatusPillType?
    public var date: String?
    public var locallyAdded: Bool
    var isContractOwner: Bool?
    public var isEmpty: Bool?
}
