import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct InsuredPeopleScreen: View {
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject var router: Router
    @ObservedObject var intentViewModel: IntentViewModel
    @ViewBuilder
    func getView(coInsured: CoInsuredListType) -> some View {
        if coInsured.locallyAdded {
            localAccessoryView(coInsured: coInsured.coInsured)
        } else {
            existingAccessoryView(coInsured: coInsured.coInsured)
        }
    }

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                let listToDisplay = listToDisplay()
                hSection {
                    hRow {
                        let hasContentBelow = !listToDisplay.isEmpty
                        ContractOwnerField(
                            hasContentBelow: hasContentBelow,
                            config: vm.config
                        )
                    }
                    .verticalPadding(0)
                    .padding(.top, .padding16)
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.transparent)

                hSection(listToDisplay) { coInsured in
                    hRow {
                        CoInsuredField(
                            coInsured: coInsured.coInsured,
                            accessoryView: getView(coInsured: coInsured),
                            includeStatusPill: coInsured.type == .added ? .added : nil,
                            date: coInsured.date
                        )
                    }
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.transparent)

                hSection {
                    hButton.LargeButton(type: .secondary) {
                        let hasExistingCoInsured = vm.config.preSelectedCoInsuredList
                            .filter { !vm.coInsuredAdded.contains($0) }
                        if hasExistingCoInsured.isEmpty {
                            editCoInsuredNavigation.coInsuredInputModel = .init(
                                actionType: .add,
                                coInsuredModel: CoInsuredModel(),
                                title: L10n.contractAddCoinsured,
                                contractId: vm.config.contractId
                            )
                        } else {
                            editCoInsuredNavigation.selectCoInsured = .init(id: vm.config.contractId)
                        }
                    } content: {
                        hText(L10n.contractAddCoinsured)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if vm.coInsuredAdded.count > 0 || vm.coInsuredDeleted.count > 0 {
                    ConfirmChangesView(editCoInsuredNavigation: editCoInsuredNavigation)
                }
                hSection {
                    CancelButton()
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    @ViewBuilder
    func localAccessoryView(coInsured: CoInsuredModel) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.Opaque.secondary)
            .onTapGesture {
                editCoInsuredNavigation.coInsuredInputModel = .init(
                    actionType: .delete,
                    coInsuredModel: coInsured,
                    title: L10n.contractRemoveCoinsuredConfirmation,
                    contractId: vm.config.contractId
                )
            }
            .accessibilityLabel(L10n.voiceoverDeleteCoinsuredButton)
    }

    @ViewBuilder
    func existingAccessoryView(coInsured: CoInsuredModel) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.Opaque.secondary)
            .onTapGesture {
                editCoInsuredNavigation.coInsuredInputModel = .init(
                    actionType: .delete,
                    coInsuredModel: coInsured,
                    title: L10n.contractRemoveCoinsuredConfirmation,
                    contractId: vm.config.contractId
                )
            }
    }

    func listToDisplay() -> [CoInsuredListType] {
        let coInsured = vm.config.contractCoInsured

        //remove locally deleted
        let removeDeleted =
            coInsured.filter { coInsured in
                !vm.coInsuredDeleted.contains(coInsured) && coInsured.terminatesOn == nil
            }
            .map { CoInsuredListType(coInsured: $0, locallyAdded: false) }

        // add locally added
        let addLocallyAdded = vm.coInsuredAdded.map { coIn in
            CoInsuredListType(
                coInsured: coIn,
                type: .added,
                date: (intentViewModel.intent.activationDate != "")
                    ? intentViewModel.intent.activationDate : vm.config.activeFrom,
                locallyAdded: true
            )
        }

        return removeDeleted + addLocallyAdded
    }
}

struct CancelButton: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        hSection {
            hButton.LargeButton(type: .ghost) {
                editCoInsuredNavigation.editCoInsuredConfig = nil
                router.dismiss()
            } content: {
                hText(L10n.generalCancelButton)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct ConfirmChangesView: View {
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    public init(
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.intentViewModel = editCoInsuredNavigation.intentViewModel
    }

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                PriceField(
                    newPremium: intentViewModel.intent.newPremium,
                    currentPremium: intentViewModel.intent.currentPremium,
                    subTitle: L10n.contractAddCoinsuredStartsFrom(
                        intentViewModel.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    )
                )
                .hWithStrikeThroughPrice(setTo: .crossOldPrice)

                hButton.LargeButton(type: .primary) {
                    editCoInsuredNavigation.showProgressScreenWithSuccess = true
                    Task {
                        await intentViewModel.performCoInsuredChanges(
                            commitId: intentViewModel.intent.id
                        )
                    }
                } content: {
                    hText(L10n.contractAddCoinsuredConfirmChanges)
                }
                .hButtonIsLoading(intentViewModel.isLoading)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct InsuredPeopleScreen_Previews: PreviewProvider {
    static var previews: some View {
        let vm = InsuredPeopleNewScreenModel()
        let config = InsuredPeopleConfig(
            id: UUID().uuidString,
            contractCoInsured: [],
            contractId: "",
            activeFrom: nil,
            numberOfMissingCoInsured: 0,
            numberOfMissingCoInsuredWithoutTermination: 0,
            displayName: "",
            preSelectedCoInsuredList: [],
            contractDisplayName: "",
            holderFirstName: "",
            holderLastName: "",
            holderSSN: nil,
            fromInfoCard: false
        )
        vm.initializeCoInsured(with: config)
        return InsuredPeopleScreen(vm: vm, intentViewModel: IntentViewModel())
    }
}

@MainActor
class InsuredPeopleNewScreenModel: ObservableObject {
    @Published var previousValue = CoInsuredModel()
    @Published var coInsuredAdded: [CoInsuredModel] = []
    @Published var coInsuredDeleted: [CoInsuredModel] = []
    @Published var noSSN = false
    var config: InsuredPeopleConfig = InsuredPeopleConfig()
    @Published var isLoading = false

    func completeList(
        coInsuredAdded: [CoInsuredModel]? = nil,
        coInsuredDeleted: [CoInsuredModel]? = nil
    ) -> [CoInsuredModel] {
        let coInsuredAdded = coInsuredAdded ?? self.coInsuredAdded
        let coInsuredDeleted = coInsuredDeleted ?? self.coInsuredDeleted
        var filterList: [CoInsuredModel] = []
        let existingList = config.contractCoInsured
        let nbOfCoInsured = config.numberOfMissingCoInsuredWithoutTermination
        let allHasMissingInfo = existingList.allSatisfy({ $0.hasMissingInfo })

        if nbOfCoInsured > 0, existingList.contains(CoInsuredModel()), allHasMissingInfo {
            if coInsuredDeleted.count > 0 || coInsuredAdded.count > 0 {
                var num: Int {
                    if coInsuredDeleted.count > 0 {
                        return nbOfCoInsured - coInsuredDeleted.count
                    } else {
                        return nbOfCoInsured - coInsuredAdded.count
                    }
                }
                for _ in 0..<num {
                    filterList.append(CoInsuredModel())
                }
                if coInsuredDeleted.count > 0 {
                    return filterList
                }
            } else if nbOfCoInsured > 0 {
                filterList = existingList
            }
        } else {
            filterList = existingList
        }
        let finalList =
            filterList.filter {
                !coInsuredDeleted.contains($0)
            } + coInsuredAdded

        return finalList.filter({ $0.terminatesOn == nil })
    }

    func listForGettingIntentFor(addCoInsured: CoInsuredModel) -> [CoInsuredModel] {
        var coInsuredAdded = self.coInsuredAdded
        coInsuredAdded.append(addCoInsured)
        return completeList(coInsuredAdded: coInsuredAdded)
    }

    func listForGettingIntentFor(removedCoInsured: CoInsuredModel) -> [CoInsuredModel] {
        var coInsuredAdded = self.coInsuredAdded
        var coInsuredDeleted = self.coInsuredDeleted
        if let index = coInsuredAdded.firstIndex(where: { coInsured in
            coInsured == removedCoInsured
        }) {
            coInsuredAdded.remove(at: index)
        } else {
            coInsuredDeleted.append(removedCoInsured)
        }

        return completeList(coInsuredAdded: coInsuredAdded, coInsuredDeleted: coInsuredDeleted)
    }

    func initializeCoInsured(with config: InsuredPeopleConfig) {
        coInsuredAdded = []
        coInsuredDeleted = []
        self.config = config
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
}
