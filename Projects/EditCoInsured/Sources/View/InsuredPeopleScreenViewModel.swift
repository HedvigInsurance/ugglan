import SwiftUI
import hCoreUI

@MainActor
class InsuredPeopleScreenViewModel: ObservableObject {
    @Published var previousValue = StakeHolder()
    @Published var stakeHoldersAdded: [StakeHolder] = []
    @Published var stakeHoldersDeleted: [StakeHolder] = []
    var config: StakeHoldersConfig
    @Published var isLoading = false

    init(stakeHolderType: StakeHolderType) {
        config = .init(stakeHolderType: stakeHolderType)
    }

    init(with config: StakeHoldersConfig) {
        self.config = config
    }

    var hasContentBelow: Bool {
        nbOfMissingStakeHoldersExcludingDeleted > 0
    }

    var hasExistingStakeHolders: Bool {
        !config.preSelectedStakeHolders.filter { !stakeHoldersAdded.contains($0) }.isEmpty
    }

    var showConfirmChangesButton: Bool {
        (stakeHoldersAdded.count >= nbOfMissingStakeHoldersExcludingDeleted && stakeHoldersAdded.count > 0)
            || stakeHoldersDeleted.count > 0
    }

    var nbOfMissingStakeHoldersExcludingDeleted: Int {
        config.numberOfMissingStakeHoldersWithoutTermination - stakeHoldersDeleted.count
    }

    var hasLocallyMissingStakeHolders: Bool {
        stakeHoldersAdded.count < nbOfMissingStakeHoldersExcludingDeleted
    }

    func getInfoCardType(type: CoInsuredFieldType?) -> NotificationType? {
        switch config.stakeHolderType {
        case .coInsured: if hasLocallyMissingStakeHolders && type != .delete { .attention } else { nil }
        case .coOwner:
            if hasLocallyMissingStakeHolders {
                .attention
            } else if stakeHoldersAdded.isEmpty && stakeHoldersDeleted.isEmpty && existingCoInsured.isEmpty {
                .info
            } else {
                nil
            }
        }
    }

    func completeList(
        stakeHoldersAdded: [StakeHolder]? = nil,
        stakeHoldersDeleted: [StakeHolder]? = nil
    ) -> [StakeHolder] {
        let added = stakeHoldersAdded ?? self.stakeHoldersAdded
        let deleted = stakeHoldersDeleted ?? self.stakeHoldersDeleted
        let existingList = config.stakeHolders
        let missingCount = config.numberOfMissingStakeHoldersWithoutTermination
        let allHasMissingInfo = existingList.allSatisfy(\.hasMissingInfo)
        let shouldShowMissingCoInsuredPlaceholder: Bool =
            missingCount > 0 && existingList.contains(StakeHolder()) && allHasMissingInfo

        var filterList: [StakeHolder] = []

        if shouldShowMissingCoInsuredPlaceholder {
            if deleted.count > 0 {
                let count = max(missingCount - deleted.count, 0)
                return Array(repeating: StakeHolder(), count: count)
            } else if added.count > 0 {
                let count = max(missingCount - added.count, 0)
                filterList = Array(repeating: StakeHolder(), count: count)
            } else {
                filterList = existingList
            }
        } else {
            filterList = existingList
        }

        let merged =
            filterList
            .filter { !deleted.contains($0) }
            + added

        return merged.filter { $0.terminatesOn == nil }
    }

    func listForGettingIntentFor(addCoInsured: StakeHolder) -> [StakeHolder] {
        self.addCoInsured(addCoInsured)
        return completeList(stakeHoldersAdded: stakeHoldersAdded)
    }

    func listForGettingIntentFor(removedCoInsured: StakeHolder) -> [StakeHolder] {
        removeCoInsured(removedCoInsured)
        return completeList(stakeHoldersAdded: stakeHoldersAdded, stakeHoldersDeleted: stakeHoldersDeleted)
    }

    func listForGettingIntentFor(editCoInsured: StakeHolder) -> [StakeHolder] {
        self.editCoInsured(editCoInsured)
        return completeList()
    }

    func initializeCoInsured(with config: StakeHoldersConfig) {
        stakeHoldersAdded = []
        stakeHoldersDeleted = []
        self.config = config
    }

    func addCoInsured(_ coInsuredModel: StakeHolder) {
        stakeHoldersAdded.append(coInsuredModel)
    }

    func removeCoInsured(_ coInsuredModel: StakeHolder) {
        if let index = stakeHoldersAdded.firstIndex(where: { coInsured in
            coInsured == coInsuredModel
        }) {
            stakeHoldersAdded.remove(at: index)
        } else {
            stakeHoldersDeleted.append(coInsuredModel)
        }
    }

    func undoDeleted(_ coInsuredModel: StakeHolder) {
        var removedCoInsured: StakeHolder {
            .init(
                firstName: coInsuredModel.firstName,
                lastName: coInsuredModel.lastName,
                SSN: coInsuredModel.SSN,
                needsMissingInfo: false
            )
        }

        if let index = stakeHoldersDeleted.firstIndex(where: {
            $0 == removedCoInsured
        }) {
            stakeHoldersDeleted.remove(at: index)
        }
    }

    func editCoInsured(_ coInsuredModel: StakeHolder) {
        if let index = stakeHoldersAdded.firstIndex(where: {
            $0 == previousValue
        }) {
            stakeHoldersAdded.remove(at: index)
        }
        addCoInsured(coInsuredModel)
    }

    func listToDisplay(type: CoInsuredFieldType?, activationDate: String?) -> [StakeHolderListType] {
        if type == .delete, nbOfMissingStakeHoldersExcludingDeleted > 0 {
            return coInsuredToDelete
        } else if type != .delete {
            return existingCoInsured + locallyAddedCoInsured(activationDate: activationDate) + missingCoInsured
        }
        return []
    }

    private var existingCoInsured: [StakeHolderListType] {
        config.stakeHolders
            .filter {
                !stakeHoldersDeleted.contains($0) && $0.terminatesOn == nil && !$0.hasMissingInfo
            }
            .map {
                StakeHolderListType(
                    stakeHolder: $0,
                    stakeHolderType: config.stakeHolderType,
                    locallyAdded: false
                )
            }
    }

    private var missingCoInsured: [StakeHolderListType] {
        let nbOfFields = nbOfMissingStakeHoldersExcludingDeleted - stakeHoldersAdded.count

        let stillHasMissingCoInsured = stakeHoldersAdded.count < nbOfMissingStakeHoldersExcludingDeleted
        var missingCoInsuredToDisplay: [StakeHolderListType] = []

        if stillHasMissingCoInsured {
            for _ in 1...nbOfFields {
                missingCoInsuredToDisplay.append(
                    StakeHolderListType(
                        stakeHolder: StakeHolder(),
                        stakeHolderType: config.stakeHolderType,
                        type: nil,
                        locallyAdded: false
                    )
                )
            }
        }
        return missingCoInsuredToDisplay
    }

    private func locallyAddedCoInsured(activationDate: String?) -> [StakeHolderListType] {
        stakeHoldersAdded.map {
            StakeHolderListType(
                stakeHolder: $0,
                stakeHolderType: config.stakeHolderType,
                type: .added,
                date: (activationDate != "")
                    ? activationDate : config.activeFrom,
                locallyAdded: true
            )
        }
    }

    private var coInsuredToDelete: [StakeHolderListType] {
        var coInsuredToDisplay: [StakeHolderListType] = []

        for _ in 1...nbOfMissingStakeHoldersExcludingDeleted {
            coInsuredToDisplay.append(
                StakeHolderListType(
                    stakeHolder: StakeHolder(),
                    stakeHolderType: config.stakeHolderType,
                    type: nil,
                    locallyAdded: false
                )
            )
        }

        return coInsuredToDisplay
    }
}
