import Foundation
import hCore

public struct StakeHoldersConfig: Codable & Equatable & Hashable, Identifiable, Sendable {
    public var id: String
    public var stakeHolders: [StakeHolder]
    public var contractId: String
    public var activeFrom: String?
    public var numberOfMissingStakeHolders: Int
    public var numberOfMissingStakeHoldersWithoutTermination: Int
    public let displayName: String
    public let exposureDisplayName: String?
    public let preSelectedStakeHolders: [StakeHolder]
    public let contractDisplayName: String
    public let holderFirstName: String
    public let holderLastName: String
    public let holderSSN: String?
    public var holderFullName: String {
        holderFirstName + " " + holderLastName
    }
    public var stakeHolderType: StakeHolderType
    public var fromInfoCard: Bool

    public init(stakeHolderType: StakeHolderType) {
        stakeHolders = []
        contractId = ""
        activeFrom = nil
        numberOfMissingStakeHolders = 0
        numberOfMissingStakeHoldersWithoutTermination = 0
        displayName = ""
        exposureDisplayName = nil
        holderFirstName = ""
        holderLastName = ""
        holderSSN = nil
        preSelectedStakeHolders = []
        contractDisplayName = ""
        fromInfoCard = false
        id = UUID().uuidString
        self.stakeHolderType = stakeHolderType
    }

    public init(
        id: String,
        stakeHolders: [StakeHolder],
        contractId: String,
        activeFrom: String?,
        numberOfMissingStakeHolders: Int,
        numberOfMissingStakeHoldersWithoutTermination: Int,
        displayName: String,
        exposureDisplayName: String?,
        preSelectedStakeHolders: [StakeHolder],
        contractDisplayName: String,
        holderFirstName: String,
        holderLastName: String,
        holderSSN: String?,
        fromInfoCard: Bool,
        stakeHolderType: StakeHolderType
    ) {
        self.id = id
        self.stakeHolders = stakeHolders
        self.contractId = contractId
        self.activeFrom = activeFrom
        self.numberOfMissingStakeHolders = numberOfMissingStakeHolders
        self.numberOfMissingStakeHoldersWithoutTermination = numberOfMissingStakeHoldersWithoutTermination
        self.displayName = displayName
        self.exposureDisplayName = exposureDisplayName
        self.preSelectedStakeHolders = preSelectedStakeHolders
        self.contractDisplayName = contractDisplayName
        self.holderFirstName = holderFirstName
        self.holderLastName = holderLastName
        self.holderSSN = holderSSN
        self.fromInfoCard = fromInfoCard
        self.stakeHolderType = stakeHolderType
    }
}

public enum StakeHolderType: String, Codable, Equatable, Hashable, Sendable {
    case coInsured, coOwner
}

extension StakeHolderType {
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

    var reviewInfo: String {
        switch self {
        case .coInsured: L10n.contractAddCoinsuredReviewInfo
        case .coOwner: L10n.contractAddCoownerReviewInfo
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

    public var addPersonalInfo: String {
        switch self {
        case .coInsured: L10n.contractCoinsuredAddPersonalInfo
        case .coOwner: "You need to add personal information to your co-owners"
        }
    }
}
