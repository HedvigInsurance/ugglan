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
        case .coInsured, .coOwner: return L10n.coinsuredEditTitle  // TODO: rename in Localize?
        }
    }

    var addButtonTitle: String {
        switch self {
        case .coInsured: return L10n.contractAddCoinsured
        case .coOwner: return "Add additional co-owner"  // TODO: Localize
        }
    }

    var defaultFieldLabel: String {
        switch self {
        case .coInsured: return L10n.contractCoinsured
        case .coOwner: return "Co-owner"  // TODO: Localize
        }
    }

    var addInfoTitle: String {
        switch self {
        case .coInsured: return L10n.contractAddConisuredInfo
        case .coOwner: return "Add co-owner information"  // TODO: Localize
        }
    }

    var removeConfirmationTitle: String {
        switch self {
        case .coInsured: return L10n.contractRemoveCoinsuredConfirmation
        case .coOwner: return "Remove co-owner"  // TODO: Localize
        }
    }

    var withoutSsnInfo: String {
        switch self {
        case .coInsured, .coOwner: return L10n.coinsuredWithoutSsnInfo  // TODO: Separate?
        }
    }

    var reviewInfo: String {
        switch self {
        case .coInsured: return L10n.contractAddCoinsuredReviewInfo
        case .coOwner: return "Please add information for all co-owners in order to proceed."  // TODO: Localize
        }
    }

    var processingText: String {
        switch self {
        case .coInsured, .coOwner: return L10n.contractAddCoinsuredProcessing  // TODO: separate?
        }
    }

    var updatedTitle: String {
        switch self {
        case .coInsured: return L10n.contractAddCoinsuredUpdatedTitle
        case .coOwner: return "Co-owners updated"  // TODO: Localize
        }
    }

    func updatedLabel(_ date: String) -> String {
        switch self {
        case .coInsured, .coOwner: return L10n.contractAddCoinsuredUpdatedLabel(date)  // TODO: separate?
        }
    }

    var missingInformationLabel: String {
        switch self {
        case .coInsured: return L10n.contractCoinsuredMissingInformationLabel
        case .coOwner: return "Missing co-owner information"  // TODO: Localize
        }
    }

    var missingAddInfo: String {
        switch self {
        case .coInsured, .coOwner: return L10n.contractCoinsuredMissingAddInfo  // TODO: separate?
        }
    }
}
