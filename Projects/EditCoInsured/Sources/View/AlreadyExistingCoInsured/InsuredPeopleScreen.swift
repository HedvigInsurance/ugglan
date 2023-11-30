import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct InsuredPeopleScreen: View {
    @PresentableStore var store: EditCoInsuredStore
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel

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
                        ContractOwnerField(hasContentBelow: hasContentBelow, config: store.coInsuredViewModel.config)
                    }
                    .verticalPadding(0)
                    .padding(.top, 16)
                }
                .withoutHorizontalPadding
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
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)

                hSection {
                    hButton.LargeButton(type: .secondary) {
                        let hasExistingCoInsured = vm.config.preSelectedCoInsuredList
                            .filter { !vm.coInsuredAdded.contains($0) }
                        if hasExistingCoInsured.isEmpty {
                            store.send(
                                .coInsuredNavigationAction(
                                    action: .openCoInsuredInput(
                                        actionType: .add,
                                        coInsuredModel: CoInsuredModel(),
                                        title: L10n.contractAddCoinsured,
                                        contractId: vm.config.contractId
                                    )
                                )
                            )
                        } else {
                            store.send(
                                .coInsuredNavigationAction(
                                    action: .openCoInsuredSelectScreen(contractId: vm.config.contractId)
                                )
                            )
                        }
                    } content: {
                        hText(L10n.contractAddCoinsured)
                    }
                    .padding(.horizontal, 16)
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if vm.coInsuredAdded.count > 0 || vm.coInsuredDeleted.count > 0 {
                    ConfirmChangesView()
                }
                CancelButton()
                    .padding(.horizontal, 16)
            }
        }
        .hFormIgnoreKeyboard()
    }

    @ViewBuilder
    func localAccessoryView(coInsured: CoInsuredModel) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.secondary)
            .onTapGesture {
                store.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            actionType: .delete,
                            coInsuredModel: coInsured,
                            title: L10n.contractRemoveCoinsuredConfirmation,
                            contractId: vm.config.contractId
                        )
                    )
                )
            }
    }

    @ViewBuilder
    func existingAccessoryView(coInsured: CoInsuredModel) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.secondary)
            .onTapGesture {
                store.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            actionType: .delete,
                            coInsuredModel: coInsured,
                            title: L10n.contractRemoveCoinsuredConfirmation,
                            contractId: vm.config.contractId
                        )
                    )
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
                date: (intentVm.activationDate != "") ? intentVm.activationDate : vm.config.activeFrom,
                locallyAdded: true
            )
        }

        return removeDeleted + addLocallyAdded
    }
}

struct CancelButton: View {
    @PresentableStore var store: EditCoInsuredStore

    var body: some View {
        hButton.LargeButton(type: .ghost) {
            store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
        } content: {
            hText(L10n.generalCancelButton)
        }
        .padding(.horizontal, 16)
    }
}

struct ConfirmChangesView: View {
    @PresentableStore var store: EditCoInsuredStore
    @ObservedObject var intentVm: IntentViewModel

    public init() {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        intentVm = store.intentViewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 2) {
                HStack(spacing: 8) {
                    hText(L10n.contractAddCoinsuredTotal)
                    Spacer()
                    if #available(iOS 16.0, *) {
                        hText(intentVm.currentPremium.formattedAmount + L10n.perMonth)
                            .strikethrough()
                            .foregroundColor(hTextColor.secondary)
                    } else {
                        hText(intentVm.currentPremium.formattedAmount + L10n.perMonth)
                            .foregroundColor(hTextColor.secondary)

                    }
                    hText(intentVm.newPremium.formattedAmount + L10n.perMonth)
                }
                hText(
                    L10n.contractAddCoinsuredStartsFrom(
                        intentVm.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    ),
                    style: .footnote
                )
                .foregroundColor(hTextColor.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            hButton.LargeButton(type: .primary) {
                store.send(.performCoInsuredChanges(commitId: intentVm.id))
                store.send(.coInsuredNavigationAction(action: .openCoInsuredProcessScreen(showSuccess: true)))
            } content: {
                hText(L10n.contractAddCoinsuredConfirmChanges)
            }
            .hButtonIsLoading(intentVm.isLoading)
        }
        .padding(.horizontal, 16)
    }
}

struct InsuredPeopleScreen_Previews: PreviewProvider {
    static var previews: some View {
        let vm = InsuredPeopleNewScreenModel()
        let intentVm = IntentViewModel()
        let config = InsuredPeopleConfig(
            currentAgreementCoInsured: [],
            contractId: "",
            activeFrom: nil,
            numberOfMissingCoInsured: 0,
            displayName: "",
            preSelectedCoInsuredList: [],
            contractDisplayName: "",
            holderFirstName: "",
            holderLastName: "",
            holderSSN: nil
        )
        vm.initializeCoInsured(with: config)
        return InsuredPeopleScreen(vm: vm, intentVm: intentVm)
    }
}

class InsuredPeopleNewScreenModel: ObservableObject {
    @Published var previousValue = CoInsuredModel()
    @Published var coInsuredAdded: [CoInsuredModel] = []
    @Published var coInsuredDeleted: [CoInsuredModel] = []
    @Published var noSSN = false
    var config: InsuredPeopleConfig = InsuredPeopleConfig()

    @PresentableStore var store: EditCoInsuredStore
    @Inject var octopus: hOctopus

    func completeList() -> [CoInsuredModel] {
        var filterList: [CoInsuredModel] = []
        let existingList = config.contractCoInsured
        let nbOfCoInsured = existingList.count

        if nbOfCoInsured > 0, existingList.contains(CoInsuredModel()) {
            if coInsuredDeleted.count > 0 {
                var num = nbOfCoInsured - coInsuredDeleted.count
                for _ in 0..<num {
                    filterList.append(CoInsuredModel())
                }
                return filterList
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

        return finalList
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

public struct CoInsuredListType: Hashable, Identifiable {
    public init(
        coInsured: CoInsuredModel,
        type: StatusPillType? = nil,
        date: String? = nil,
        locallyAdded: Bool,
        isContractOwner: Bool? = nil
    ) {
        self.coInsured = coInsured
        self.type = type
        self.date = date
        self.locallyAdded = locallyAdded
        self.isContractOwner = isContractOwner
    }

    public var id: String? {
        return coInsured.id
    }
    public var coInsured: CoInsuredModel
    public var type: StatusPillType?
    public var date: String?
    var locallyAdded: Bool
    var isContractOwner: Bool?
}

public struct InsuredPeopleConfig: Codable & Equatable & Hashable {
    public var contractCoInsured: [CoInsuredModel]
    public var contractId: String
    public var activeFrom: String?
    public var numberOfMissingCoInsured: Int
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
        self.displayName = ""
        self.holderFirstName = ""
        self.holderLastName = ""
        self.holderSSN = nil
        self.preSelectedCoInsuredList = []
        self.contractDisplayName = ""
    }

    public init(
        currentAgreementCoInsured: [CoInsuredModel],
        contractId: String,
        activeFrom: String?,
        numberOfMissingCoInsured: Int,
        displayName: String,
        preSelectedCoInsuredList: [CoInsuredModel],
        contractDisplayName: String,
        holderFirstName: String,
        holderLastName: String,
        holderSSN: String?
    ) {
        self.contractCoInsured = currentAgreementCoInsured
        self.contractId = contractId
        self.activeFrom = activeFrom
        self.numberOfMissingCoInsured = numberOfMissingCoInsured
        self.displayName = displayName
        self.preSelectedCoInsuredList = preSelectedCoInsuredList
        self.contractDisplayName = contractDisplayName
        self.holderFirstName = holderFirstName
        self.holderLastName = holderLastName
        self.holderSSN = holderSSN
    }
}
