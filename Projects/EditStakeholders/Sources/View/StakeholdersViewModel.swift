import SwiftUI
import hCoreUI

@MainActor
class StakeholdersViewModel: ObservableObject {
    @Published var previousValue = Stakeholder()
    @Published var stakeholdersAdded: [Stakeholder] = []
    @Published var stakeholdersDeleted: [Stakeholder] = []
    var config: StakeholdersConfig
    @Published var isLoading = false

    init(stakeholderType: StakeholderType) {
        config = .init(stakeholderType: stakeholderType)
    }

    init(with config: StakeholdersConfig) {
        self.config = config
    }

    var hasContentBelow: Bool {
        nbOfMissingStakeholdersExcludingDeleted > 0
    }

    var hasExistingStakeholders: Bool {
        !config.preSelectedStakeholders.filter { !stakeholdersAdded.contains($0) }.isEmpty
    }

    var showConfirmChangesButton: Bool {
        (stakeholdersAdded.count >= nbOfMissingStakeholdersExcludingDeleted && stakeholdersAdded.count > 0)
            || stakeholdersDeleted.count > 0
    }

    var nbOfMissingStakeholdersExcludingDeleted: Int {
        config.numberOfMissingStakeholdersWithoutTermination - stakeholdersDeleted.count
    }

    var hasLocallyMissingStakeholders: Bool {
        stakeholdersAdded.count < nbOfMissingStakeholdersExcludingDeleted
    }

    func getInfoCardType(type: StakeholderFieldType?) -> NotificationType? {
        switch config.stakeholderType {
        case .coInsured: if hasLocallyMissingStakeholders && type != .delete { .attention } else { nil }
        case .coOwner:
            if hasLocallyMissingStakeholders {
                .attention
            } else if stakeholdersAdded.isEmpty && stakeholdersDeleted.isEmpty && existingStakeholders.isEmpty {
                .info
            } else {
                nil
            }
        }
    }

    func completeList(
        stakeholdersAdded: [Stakeholder]? = nil,
        stakeholdersDeleted: [Stakeholder]? = nil
    ) -> [Stakeholder] {
        let added = stakeholdersAdded ?? self.stakeholdersAdded
        let deleted = stakeholdersDeleted ?? self.stakeholdersDeleted
        let existingList = config.stakeholders
        let missingCount = config.numberOfMissingStakeholdersWithoutTermination
        let allHasMissingInfo = existingList.allSatisfy(\.hasMissingInfo)
        let shouldShowMissingStakeholderPlaceholder: Bool =
            missingCount > 0 && existingList.contains(Stakeholder()) && allHasMissingInfo

        var filterList: [Stakeholder] = []

        if shouldShowMissingStakeholderPlaceholder {
            if deleted.count > 0 {
                let count = max(missingCount - deleted.count, 0)
                return Array(repeating: Stakeholder(), count: count)
            } else if added.count > 0 {
                let count = max(missingCount - added.count, 0)
                filterList = Array(repeating: Stakeholder(), count: count)
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

    func listForGettingIntentFor(addStakeholder: Stakeholder) -> [Stakeholder] {
        self.addStakeholder(addStakeholder)
        return completeList(stakeholdersAdded: stakeholdersAdded)
    }

    func listForGettingIntentFor(removedStakeholder: Stakeholder) -> [Stakeholder] {
        removeStakeholder(removedStakeholder)
        return completeList(stakeholdersAdded: stakeholdersAdded, stakeholdersDeleted: stakeholdersDeleted)
    }

    func listForGettingIntentFor(editStakeholder: Stakeholder) -> [Stakeholder] {
        self.editStakeholder(editStakeholder)
        return completeList()
    }

    func initializeStakeholders(with config: StakeholdersConfig) {
        stakeholdersAdded = []
        stakeholdersDeleted = []
        self.config = config
    }

    func addStakeholder(_ stakeholderModel: Stakeholder) {
        stakeholdersAdded.append(stakeholderModel)
    }

    func removeStakeholder(_ stakeholderModel: Stakeholder) {
        if let index = stakeholdersAdded.firstIndex(where: { stakeholder in
            stakeholder == stakeholderModel
        }) {
            stakeholdersAdded.remove(at: index)
        } else {
            stakeholdersDeleted.append(stakeholderModel)
        }
    }

    func undoDeleted(_ stakeholderModel: Stakeholder) {
        var removedStakeholder: Stakeholder {
            .init(
                firstName: stakeholderModel.firstName,
                lastName: stakeholderModel.lastName,
                SSN: stakeholderModel.SSN,
                needsMissingInfo: false
            )
        }

        if let index = stakeholdersDeleted.firstIndex(where: {
            $0 == removedStakeholder
        }) {
            stakeholdersDeleted.remove(at: index)
        }
    }

    func editStakeholder(_ stakeholderModel: Stakeholder) {
        if let index = stakeholdersAdded.firstIndex(where: {
            $0 == previousValue
        }) {
            stakeholdersAdded.remove(at: index)
        }
        addStakeholder(stakeholderModel)
    }

    func listToDisplay(type: StakeholderFieldType?, activationDate: String?) -> [StakeholderItem] {
        if type == .delete, nbOfMissingStakeholdersExcludingDeleted > 0 {
            return stakeholdersToDelete
        } else if type != .delete {
            return existingStakeholders + locallyAddedStakeholders(activationDate: activationDate) + missingStakeholders
        }
        return []
    }

    private var existingStakeholders: [StakeholderItem] {
        config.stakeholders
            .filter {
                !stakeholdersDeleted.contains($0) && $0.terminatesOn == nil && !$0.hasMissingInfo
            }
            .map {
                StakeholderItem(
                    stakeholder: $0,
                    stakeholderType: config.stakeholderType,
                    locallyAdded: false
                )
            }
    }

    private var missingStakeholders: [StakeholderItem] {
        let nbOfFields = nbOfMissingStakeholdersExcludingDeleted - stakeholdersAdded.count

        let stillHasMissingStakeholders = stakeholdersAdded.count < nbOfMissingStakeholdersExcludingDeleted
        var missingStakeholdersToDisplay: [StakeholderItem] = []

        if stillHasMissingStakeholders {
            for _ in 1...nbOfFields {
                missingStakeholdersToDisplay.append(
                    StakeholderItem(
                        stakeholder: Stakeholder(),
                        stakeholderType: config.stakeholderType,
                        type: nil,
                        locallyAdded: false
                    )
                )
            }
        }
        return missingStakeholdersToDisplay
    }

    private func locallyAddedStakeholders(activationDate: String?) -> [StakeholderItem] {
        stakeholdersAdded.map {
            StakeholderItem(
                stakeholder: $0,
                stakeholderType: config.stakeholderType,
                type: .added,
                date: (activationDate != "")
                    ? activationDate : config.activeFrom,
                locallyAdded: true
            )
        }
    }

    private var stakeholdersToDelete: [StakeholderItem] {
        var stakeholdersToDisplay: [StakeholderItem] = []

        for _ in 1...nbOfMissingStakeholdersExcludingDeleted {
            stakeholdersToDisplay.append(
                StakeholderItem(
                    stakeholder: Stakeholder(),
                    stakeholderType: config.stakeholderType,
                    type: nil,
                    locallyAdded: false
                )
            )
        }

        return stakeholdersToDisplay
    }
}
