import Foundation
import SwiftUI
import hCore

public struct CoInsuredModel: Codable, Hashable, Equatable, Sendable {
    public let SSN: String?
    public let hasMissingInfo: Bool
    public var firstName: String?
    public var lastName: String?
    public var birthDate: String?
    public let activatesOn: ServerBasedDate?
    public let terminatesOn: ServerBasedDate?
    public var isTerminated: Bool {
        terminatesOn != nil
    }

    public var fullName: String? {
        guard let firstName, let lastName else { return nil }
        return firstName + " " + lastName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: String {
        (fullName ?? "") + (formattedSSN ?? "") + (birthDate ?? "")
    }

    @MainActor
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
        hasMissingInfo = needsMissingInfo
        self.activatesOn = activatesOn
        self.terminatesOn = terminatesOn
    }

    public var formattedSSN: String? {
        SSN?.replacingOccurrences(of: "-", with: "")
    }

    public var hasMissingData: Bool {
        fullName == nil
    }

    public static func == (lhs: CoInsuredModel, rhs: CoInsuredModel) -> Bool {
        lhs.fullName == rhs.fullName
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

public struct CoInsuredConfigModel: Identifiable, Equatable {
    public init(
        configs: [InsuredPeopleConfig]
    ) {
        self.configs = configs
    }

    public var id: String?
    public var configs: [InsuredPeopleConfig]
}
