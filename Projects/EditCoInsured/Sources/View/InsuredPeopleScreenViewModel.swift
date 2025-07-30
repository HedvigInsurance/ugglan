import SwiftUI

@MainActor
class InsuredPeopleScreenViewModel: ObservableObject {
    @Published var previousValue = CoInsuredModel()
    @Published var coInsuredAdded: [CoInsuredModel] = []
    @Published var coInsuredDeleted: [CoInsuredModel] = []
    @Published var noSSN = false
    var config: InsuredPeopleConfig = InsuredPeopleConfig()
    @Published var isLoading = false
    @Published var showSavebutton: Bool = false
    @Published var showInfoCard: Bool = false

    var shouldShowSaveChangesButton: Bool {
        let totalAddedCoInsured = config.contractCoInsured.count + coInsuredAdded.count
        return totalAddedCoInsured < config.numberOfMissingCoInsuredWithoutTermination
    }

    var hasContentBelow: Bool {
        nbOfMissingCoInsuredExcludingDeleted > 0
    }

    var hasExistingCoInsured: Bool {
        !config.preSelectedCoInsuredList.filter { !coInsuredAdded.contains($0) }.isEmpty
    }

    var showConfirmChangesButton: Bool {
        (coInsuredAdded.count >= nbOfMissingCoInsuredExcludingDeleted && coInsuredAdded.count > 0)
            || coInsuredDeleted.count > 0
    }

    var nbOfMissingCoInsuredExcludingDeleted: Int {
        config.numberOfMissingCoInsuredWithoutTermination - coInsuredDeleted.count
    }

    func showInfoCard(type: CoInsuredFieldType?) -> Bool {
        return coInsuredAdded.count < nbOfMissingCoInsuredExcludingDeleted && type != .delete
    }

    func completeList(
        coInsuredAdded: [CoInsuredModel]? = nil,
        coInsuredDeleted: [CoInsuredModel]? = nil
    ) -> [CoInsuredModel] {
        let added = coInsuredAdded ?? self.coInsuredAdded
        let deleted = coInsuredDeleted ?? self.coInsuredDeleted
        let existingList = config.contractCoInsured
        let missingCount = config.numberOfMissingCoInsuredWithoutTermination
        let allHasMissingInfo = existingList.allSatisfy({ $0.hasMissingInfo })
        let shouldShowMissingCoInsuredPlaceholder: Bool =
            missingCount > 0 && existingList.contains(CoInsuredModel()) && allHasMissingInfo

        var filterList: [CoInsuredModel] = []

        if shouldShowMissingCoInsuredPlaceholder {
            if deleted.count > 0 {
                let count = max(missingCount - deleted.count, 0)
                return Array(repeating: CoInsuredModel(), count: count)
            } else if added.count > 0 {
                let count = max(missingCount - added.count, 0)
                filterList = Array(repeating: CoInsuredModel(), count: count)
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

    func listForGettingIntentFor(addCoInsured: CoInsuredModel) -> [CoInsuredModel] {
        self.addCoInsured(addCoInsured)
        return completeList(coInsuredAdded: self.coInsuredAdded)
    }

    func listForGettingIntentFor(removedCoInsured: CoInsuredModel) -> [CoInsuredModel] {
        removeCoInsured(removedCoInsured)
        return completeList(coInsuredAdded: self.coInsuredAdded, coInsuredDeleted: self.coInsuredDeleted)
    }

    func listForGettingIntentFor(editCoInsured: CoInsuredModel) -> [CoInsuredModel] {
        self.editCoInsured(editCoInsured)
        return completeList()
    }

    func initializeCoInsured(with config: InsuredPeopleConfig) {
        coInsuredAdded = []
        coInsuredDeleted = []
        self.config = config
        let nbOfMissingCoInsured = config.numberOfMissingCoInsuredWithoutTermination
        self.showSavebutton = coInsuredAdded.count >= nbOfMissingCoInsured && nbOfMissingCoInsured != 0
    }

    func addCoInsured(_ coInsuredModel: CoInsuredModel) {
        coInsuredAdded.append(coInsuredModel)
    }

    func removeCoInsured(_ coInsuredModel: CoInsuredModel) {
        if let index = coInsuredAdded.firstIndex(where: { coInsured in
            coInsured == coInsuredModel
        }) {
            coInsuredAdded.remove(at: index)
        } else {
            coInsuredDeleted.append(coInsuredModel)
        }
    }

    func undoDeleted(_ coInsuredModel: CoInsuredModel) {
        var removedCoInsured: CoInsuredModel {
            return
                .init(
                    firstName: coInsuredModel.firstName,
                    lastName: coInsuredModel.lastName,
                    SSN: coInsuredModel.SSN,
                    needsMissingInfo: false
                )
        }

        if let index = coInsuredDeleted.firstIndex(where: {
            $0 == removedCoInsured
        }) {
            coInsuredDeleted.remove(at: index)
        }
    }

    func editCoInsured(_ coInsuredModel: CoInsuredModel) {
        if let index = coInsuredAdded.firstIndex(where: {
            $0 == previousValue
        }) {
            coInsuredAdded.remove(at: index)
        }
        addCoInsured(coInsuredModel)
    }

    func listToDisplay(type: CoInsuredFieldType?, activationDate: String?) -> [CoInsuredListType] {
        if type == .delete && nbOfMissingCoInsuredExcludingDeleted > 0 {
            return coInsuredToDelete
        } else if type != .delete {
            return existingCoInsured + locallyAddedCoInsured(activationDate: activationDate) + missingCoInsured
        }
        return []
    }

    private var existingCoInsured: [CoInsuredListType] {
        return config.contractCoInsured
            .filter {
                !coInsuredDeleted.contains($0) && $0.terminatesOn == nil && !$0.hasMissingInfo
            }
            .map { CoInsuredListType(coInsured: $0, locallyAdded: false) }
    }

    private var missingCoInsured: [CoInsuredListType] {
        let nbOfFields = nbOfMissingCoInsuredExcludingDeleted - coInsuredAdded.count

        let stillHasMissingCoInsured = coInsuredAdded.count < nbOfMissingCoInsuredExcludingDeleted
        var missingCoInsuredToDisplay: [CoInsuredListType] = []

        if stillHasMissingCoInsured {
            for _ in 1...nbOfFields {
                missingCoInsuredToDisplay.append(
                    CoInsuredListType(
                        coInsured: CoInsuredModel(),
                        type: nil,
                        locallyAdded: false
                    )
                )
            }
        }
        return missingCoInsuredToDisplay
    }

    private func locallyAddedCoInsured(activationDate: String?) -> [CoInsuredListType] {
        return coInsuredAdded.map {
            CoInsuredListType(
                coInsured: $0,
                type: .added,
                date: (activationDate != "")
                    ? activationDate : config.activeFrom,
                locallyAdded: true
            )
        }
    }

    private var coInsuredToDelete: [CoInsuredListType] {
        var coInsuredToDisplay: [CoInsuredListType] = []

        for _ in 1...nbOfMissingCoInsuredExcludingDeleted {
            coInsuredToDisplay.append(
                CoInsuredListType(
                    coInsured: CoInsuredModel(),
                    type: nil,
                    locallyAdded: false
                )
            )
        }

        return coInsuredToDisplay
    }
}
