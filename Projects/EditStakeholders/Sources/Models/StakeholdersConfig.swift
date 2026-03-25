import Foundation
import hCore

public struct StakeholdersConfig: Codable & Equatable & Hashable, Identifiable, Sendable {
    public let id: String
    public let stakeholders: [Stakeholder]
    public let contractId: String
    public let activeFrom: String?
    public let numberOfMissingStakeholders: Int
    public let numberOfMissingStakeholdersWithoutTermination: Int
    public let displayName: String
    public let exposureDisplayName: String?
    public let preSelectedStakeholders: [Stakeholder]
    public let contractDisplayName: String
    public let holderFirstName: String
    public let holderLastName: String
    public let holderSSN: String?
    public var holderFullName: String {
        holderFirstName + " " + holderLastName
    }
    public let stakeholderType: StakeholderType
    public let fromInfoCard: Bool

    public init(stakeholderType: StakeholderType) {
        stakeholders = []
        contractId = ""
        activeFrom = nil
        numberOfMissingStakeholders = 0
        numberOfMissingStakeholdersWithoutTermination = 0
        displayName = ""
        exposureDisplayName = nil
        holderFirstName = ""
        holderLastName = ""
        holderSSN = nil
        preSelectedStakeholders = []
        contractDisplayName = ""
        fromInfoCard = false
        id = UUID().uuidString
        self.stakeholderType = stakeholderType
    }

    public init(
        id: String,
        stakeholders: [Stakeholder],
        contractId: String,
        activeFrom: String?,
        numberOfMissingStakeholders: Int,
        numberOfMissingStakeholdersWithoutTermination: Int,
        displayName: String,
        exposureDisplayName: String?,
        preSelectedStakeholders: [Stakeholder],
        contractDisplayName: String,
        holderFirstName: String,
        holderLastName: String,
        holderSSN: String?,
        fromInfoCard: Bool,
        stakeholderType: StakeholderType
    ) {
        self.id = id
        self.stakeholders = stakeholders
        self.contractId = contractId
        self.activeFrom = activeFrom
        self.numberOfMissingStakeholders = numberOfMissingStakeholders
        self.numberOfMissingStakeholdersWithoutTermination = numberOfMissingStakeholdersWithoutTermination
        self.displayName = displayName
        self.exposureDisplayName = exposureDisplayName
        self.preSelectedStakeholders = preSelectedStakeholders
        self.contractDisplayName = contractDisplayName
        self.holderFirstName = holderFirstName
        self.holderLastName = holderLastName
        self.holderSSN = holderSSN
        self.fromInfoCard = fromInfoCard
        self.stakeholderType = stakeholderType
    }
}

public enum StakeholderType: String, Codable, Equatable, Hashable, Sendable, Comparable {
    public static func < (lhs: StakeholderType, rhs: StakeholderType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    case coInsured, coOwner
}

extension StakeholderType {
    var editTitle: String {
        switch self {
        case .coInsured, .coOwner: L10n.coinsuredEditTitle  // TODO: rename in Localize?
        }
    }

    var addButtonTitle: String {
        switch self {
        case .coInsured: L10n.contractAddCoinsured
        case .coOwner: L10n.contractAddAdditionalCoowner
        }
    }

    var defaultFieldLabel: String {
        switch self {
        case .coInsured: L10n.contractCoinsured
        case .coOwner: L10n.contractCoowner
        }
    }

    var addInfoTitle: String {
        switch self {
        case .coInsured: L10n.contractAddConisuredInfo
        case .coOwner: L10n.contractAddAdditionalCoowner
        }
    }

    var removeConfirmationTitle: String {
        switch self {
        case .coInsured: L10n.contractRemoveCoinsuredConfirmation
        case .coOwner: L10n.contractRemoveCoownerConfirmation
        }
    }

    var withoutSsnInfo: String {
        switch self {
        case .coInsured, .coOwner: L10n.coinsuredWithoutSsnInfo  // TODO: Separate?
        }
    }

    func reviewInfo(hasMissingStakeholders: Bool) -> String {
        switch self {
        case .coInsured: L10n.contractAddCoinsuredReviewInfo
        case .coOwner:
            hasMissingStakeholders ? L10n.contractAddCoownerReviewInfo : L10n.contractAddAdditionalCoownerInfo
        }
    }

    var processingText: String {
        switch self {
        case .coInsured, .coOwner: L10n.contractAddCoinsuredProcessing  // TODO: separate?
        }
    }

    var updatedTitle: String {
        switch self {
        case .coInsured: L10n.contractAddCoinsuredUpdatedTitle
        case .coOwner: L10n.contractAddCoownerUpdatedTitle
        }
    }

    func updatedLabel(_ date: String) -> String {
        switch self {
        case .coInsured, .coOwner: L10n.contractAddCoinsuredUpdatedLabel(date)  // TODO: separate?
        }
    }

    var missingInformationLabel: String {
        switch self {
        case .coInsured: L10n.contractCoinsuredMissingInformationLabel
        case .coOwner: L10n.contractCoownersMissingInfoText
        }
    }

    var missingAddInfo: String {
        switch self {
        case .coInsured, .coOwner: L10n.contractCoinsuredMissingAddInfo  // TODO: separate?
        }
    }

    public var missingAddInfoText: String {
        switch self {
        case .coInsured: L10n.contractCoinsuredMissingInfoText
        case .coOwner: L10n.contractCoownersMissingInfoText
        }
    }

    public var addPersonalInfo: String {
        switch self {
        case .coInsured: L10n.contractCoinsuredAddPersonalInfo
        case .coOwner: L10n.contractCoownersAddPersonalInfo
        }
    }
}

extension StakeholderType {
    private var trackingPrefix: String {
        switch self {
        case .coInsured: "CoInsured"
        case .coOwner: "CoOwner"
        }
    }

    func trackingName(for view: String) -> String {
        "\(trackingPrefix)\(view)"
    }
}
