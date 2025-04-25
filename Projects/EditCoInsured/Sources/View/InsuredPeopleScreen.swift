import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleScreen: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var vm: InsuredPeopleScreenViewModel
    @ObservedObject var intentViewModel: IntentViewModel
    let type: CoInsuredFieldType?

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                let listToDisplay = listToDisplay()

                let nbOfMissingoInsured =
                    vm.config.numberOfMissingCoInsuredWithoutTermination - vm.coInsuredDeleted.count
                let hasContentBelow = nbOfMissingoInsured > 0

                Group {
                    contractOwnerField(hasContentBelow: !listToDisplay.isEmpty || hasContentBelow)
                    coInsuredSection(list: listToDisplay)
                    buttonSection
                }
                .hWithoutHorizontalPadding([.section])
            }
            .sectionContainerStyle(.transparent)

            infoCardSection
        }
        .hFormAttachToBottom {
            VStack(spacing: .padding8) {
                if vm.showSavebutton {
                    saveChangesButton
                }

                if vm.coInsuredAdded.count > 0 || vm.coInsuredDeleted.count > 0 {
                    ConfirmChangesView(editCoInsuredNavigation: editCoInsuredNavigation)
                }
                hSection {
                    CancelButton()
                        .disabled(intentViewModel.isLoading)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    private var saveChangesButton: some View {
        hSection {
            hButton.LargeButton(type: .primary) {
                Task {
                    await intentViewModel.performCoInsuredChanges(
                        commitId: intentViewModel.intent.id
                    )
                }
                editCoInsuredNavigation.showProgressScreenWithoutSuccess = true
                editCoInsuredNavigation.editCoInsuredConfig = nil
            } content: {
                hText(L10n.generalSaveChangesButton)
            }
            .hButtonIsLoading(intentViewModel.isLoading)
            .disabled(
                (vm.config.contractCoInsured.count + vm.coInsuredAdded.count)
                    < vm.config.numberOfMissingCoInsuredWithoutTermination
            )
        }
        .sectionContainerStyle(.transparent)
    }

    private func contractOwnerField(hasContentBelow: Bool) -> some View {
        hSection {
            hRow {
                ContractOwnerField(
                    hasContentBelow: hasContentBelow,
                    config: vm.config
                )
            }
            .verticalPadding(0)
            .padding(.top, .padding16)
        }
    }

    private func coInsuredSection(list: [CoInsuredListType]) -> some View {
        hSection(list) { coInsured in
            hRow {
                CoInsuredField(
                    coInsured: coInsured.coInsured,
                    accessoryView: getAccesoryView(coInsured: coInsured),
                    statusPill: coInsured.type == .added ? .added : nil,
                    date: coInsured.date
                )
            }
        }
    }

    @ViewBuilder
    private var buttonSection: (some View)? {
        if vm.config.numberOfMissingCoInsuredWithoutTermination == 0 {
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
            .hWithoutHorizontalPadding([.row])
        }
    }

    @ViewBuilder
    private var infoCardSection: some View {
        let missingNumberOfCoInsured = vm.config.numberOfMissingCoInsured
        if vm.coInsuredAdded.count < missingNumberOfCoInsured && type != .delete {
            hSection {
                InfoCard(text: L10n.contractAddCoinsuredReviewInfo, type: .attention)
            }
        }
    }

    /* TODO: REFACTOR */
    private func listToDisplay() -> [CoInsuredListType] {
        var locallyAndExistingCoInsured: [CoInsuredListType] = []
        var coInsuredWithMissingInfo: [CoInsuredListType] = []

        let nbOfMissingCoInsured = vm.config.numberOfMissingCoInsuredWithoutTermination - vm.coInsuredDeleted.count

        if type == .delete && nbOfMissingCoInsured > 0 {
            for _ in 1...nbOfMissingCoInsured {
                locallyAndExistingCoInsured.append(
                    CoInsuredListType(
                        coInsured: CoInsuredModel(),
                        type: nil,
                        locallyAdded: false
                    )
                )
            }
        } else if type != .delete {
            // add locally added
            locallyAndExistingCoInsured = vm.coInsuredAdded.map {
                CoInsuredListType(
                    coInsured: $0,
                    type: .added,
                    date: (intentViewModel.intent.activationDate != "")
                        ? intentViewModel.intent.activationDate : vm.config.activeFrom,
                    locallyAdded: true
                )
            }

            // add missing
            if vm.coInsuredAdded.count < nbOfMissingCoInsured {
                let nbOfFields = nbOfMissingCoInsured - vm.coInsuredAdded.count
                for _ in 1...nbOfFields {
                    coInsuredWithMissingInfo.append(
                        CoInsuredListType(
                            coInsured: CoInsuredModel(),
                            type: nil,
                            locallyAdded:
                                false
                        )
                    )
                }
            }
        }

        // add deleted
        let removeDeleted =
            vm.allHasMissingInfo
            ? vm.config.contractCoInsured
                .filter({ !vm.coInsuredDeleted.contains($0) && $0.isTerminated })
                .compactMap { CoInsuredListType(coInsured: $0, locallyAdded: false) } : []

        return removeDeleted + locallyAndExistingCoInsured + coInsuredWithMissingInfo
    }

    @ViewBuilder
    private func getAccesoryView(coInsured: CoInsuredListType) -> some View {
        if coInsured.coInsured.hasMissingData && type != .delete {
            getAccesoryView(for: .empty, coInsured: coInsured.coInsured)
        } else if coInsured.locallyAdded {
            getAccesoryView(for: .localEdit, coInsured: coInsured.coInsured)
        } else {
            getAccesoryView(for: .delete, coInsured: coInsured.coInsured)
        }
    }

    enum CoInsuredFieldType {
        case empty
        case localEdit
        case delete

        @MainActor
        var icon: ImageAsset? {
            switch self {
            case .empty:
                return hCoreUIAssets.plusSmall
            case .delete:
                return hCoreUIAssets.closeSmall
            case .localEdit:
                return nil
            }
        }

        @hColorBuilder @MainActor
        var iconColor: some hColor {
            switch self {
            case .delete:
                hTextColor.Opaque.secondary
            default:
                hTextColor.Opaque.primary
            }

        }

        var text: String? {
            switch self {
            case .empty:
                return L10n.generalAddInfoButton
            case .delete:
                return nil
            case .localEdit:
                return L10n.Claims.Edit.Screen.title
            }
        }

        var action: CoInsuredAction {
            switch self {
            case .empty:
                return .add
            case .localEdit:
                return .edit
            case .delete:
                return .delete
            }
        }

        var title: String {
            switch self {
            case .empty:
                return L10n.contractAddConisuredInfo
            case .localEdit:
                return L10n.contractAddConisuredInfo
            case .delete:
                return L10n.contractRemoveCoinsuredConfirmation
            }
        }
    }

    private func getAccesoryView(for type: CoInsuredFieldType, coInsured: CoInsuredModel) -> some View {
        HStack {
            if let text = type.text {
                hText(text)
            }
            if let icon = type.icon {
                Image(uiImage: icon.image)
                    .foregroundColor(type.iconColor)
            }
        }
        .onTapGesture {
            let hasExistingCoInsured = vm.config.preSelectedCoInsuredList.filter { !vm.coInsuredAdded.contains($0) }
            if type == .empty && !hasExistingCoInsured.isEmpty {
                editCoInsuredNavigation.selectCoInsured = .init(id: vm.config.contractId)
            } else {
                editCoInsuredNavigation.coInsuredInputModel = .init(
                    actionType: type.action,
                    coInsuredModel: type == .empty ? CoInsuredModel() : coInsured,
                    title: type.title,
                    contractId: vm.config.contractId
                )
            }
        }

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

@MainActor
class InsuredPeopleScreenViewModel: ObservableObject {
    @Published var previousValue = CoInsuredModel()
    @Published var coInsuredAdded: [CoInsuredModel] = []
    @Published var coInsuredDeleted: [CoInsuredModel] = []
    @Published var noSSN = false
    var config: InsuredPeopleConfig = InsuredPeopleConfig()
    @Published var isLoading = false
    @Published var showSavebutton: Bool = false
    var allHasMissingInfo: Bool {
        config.contractCoInsured.allSatisfy({ !$0.hasMissingInfo })
    }

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
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let vm = InsuredPeopleScreenViewModel()
    let config = InsuredPeopleConfig(
        id: UUID().uuidString,
        contractCoInsured: [
            .init(
                firstName: "first name",
                lastName: "last name",
                SSN: "00000000-0000",
                birthDate: "2000-01-01",
                needsMissingInfo: false,
                activatesOn: "2025-04-22",
                terminatesOn: nil
            )
        ],
        contractId: "",
        activeFrom: nil,
        numberOfMissingCoInsured: 0,
        numberOfMissingCoInsuredWithoutTermination: 0,
        displayName: "",
        exposureDisplayName: nil,
        preSelectedCoInsuredList: [],
        contractDisplayName: "",
        holderFirstName: "First Name",
        holderLastName: "Last Name",
        holderSSN: "00000000-0000",
        fromInfoCard: false
    )
    vm.initializeCoInsured(with: config)
    return InsuredPeopleScreen(vm: vm, intentViewModel: IntentViewModel(), type: .localEdit)
}
