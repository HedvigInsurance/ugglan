import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct InsuredPeopleScreen: View {
    @PresentableStore var store: ContractStore
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
                let coInsured = vm.config.currentAgreementCoInsured
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
                        let hasExistingCoInsured = store.state
                            .fetchAllCoInsuredNotInContract(contractId: vm.config.contractId)
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
        var finalList: [CoInsuredListType] = []
        var addedCoInsured: [CoInsuredListType] = []
        let coInsured = vm.config.currentAgreementCoInsured
        if let upcomingCoInsured = vm.config.upcomingAgreementCoInsured {
            let sortedUpcoming = Set(upcomingCoInsured)
                .sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
            sortedUpcoming.forEach { upcomingCoInsured in
                if coInsured.contains(CoInsuredModel()) {
                    if !vm.coInsuredDeleted.contains(upcomingCoInsured) {
                        finalList.append(
                            CoInsuredListType(coInsured: upcomingCoInsured, type: nil, locallyAdded: false)
                        )
                    }
                } else {
                    if coInsured.contains(upcomingCoInsured) {
                        if !vm.coInsuredDeleted.contains(upcomingCoInsured) {
                            //remaining
                            finalList.append(
                                CoInsuredListType(coInsured: upcomingCoInsured, type: nil, locallyAdded: false)
                            )
                        }
                    } else {
                        if !vm.coInsuredDeleted.contains(upcomingCoInsured) {
                            addedCoInsured.append(
                                CoInsuredListType(
                                    coInsured: upcomingCoInsured,
                                    type: .added,
                                    date: (intentVm.activationDate != "")
                                        ? intentVm.activationDate : vm.config.activeFrom,
                                    locallyAdded: false
                                )
                            )
                        }
                    }
                }
            }
        } else {
            let sortedCoInsured = Set(coInsured)
                .sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
            sortedCoInsured.forEach { coInsured in

                if vm.coInsuredDeleted.first(where: {
                    $0 == coInsured
                }) == nil {

                    finalList.append(CoInsuredListType(coInsured: coInsured, type: nil, locallyAdded: false))
                }
            }
        }

        // adding locally added ones
        vm.coInsuredAdded.forEach { coInsured in
            addedCoInsured.append(
                CoInsuredListType(
                    coInsured: coInsured,
                    type: .added,
                    date: (intentVm.activationDate != "") ? intentVm.activationDate : vm.config.activeFrom,
                    locallyAdded: true
                )
            )
        }
        return finalList + addedCoInsured
    }
}

struct CancelButton: View {
    @PresentableStore var store: ContractStore

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
    @PresentableStore var store: ContractStore
    @ObservedObject var intentVm: IntentViewModel

    public init() {
        let store: ContractStore = globalPresentableStoreContainer.get()
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
            contract: Contract(
                id: "",
                currentAgreement: Agreement(
                    premium: MonetaryAmount(amount: 0, currency: ""),
                    displayItems: [],
                    productVariant: ProductVariant(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: ""
                    ),
                    coInsured: []
                ),
                exposureDisplayName: "",
                masterInceptionDate: "",
                terminationDate: nil,
                supportsAddressChange: true,
                supportsCoInsured: true,
                upcomingChangedAgreement: Agreement(
                    premium: MonetaryAmount(amount: 0, currency: ""),
                    displayItems: [],
                    productVariant: ProductVariant(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: ""
                    ),
                    coInsured: []
                ),
                upcomingRenewal: ContractRenewal(
                    renewalDate: "",
                    draftCertificateUrl: ""
                ),
                firstName: "",
                lastName: "",
                ssn: "",
                typeOfContract: .seApartmentBrf
            )
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

    @PresentableStore var store: ContractStore
    @Inject var octopus: hOctopus

    func completeList() -> [CoInsuredModel] {
        var filterList: [CoInsuredModel] = []
        let upComingList = config.upcomingAgreementCoInsured

        if let upComingList, !upComingList.contains(CoInsuredModel()) {
            filterList = upComingList

        } else {
            let existingList = config.currentAgreementCoInsured
            let nbOfCoInsured = existingList.count

            if nbOfCoInsured > 0, existingList.contains(CoInsuredModel()) {
                let nbOfUpcomingCoInsured = upComingList?.count
                if coInsuredDeleted.count > 0 {
                    var num: Int {
                        if let nbOfUpcomingCoInsured, nbOfUpcomingCoInsured < nbOfCoInsured,
                            !(upComingList?.isEmpty ?? false)
                        {
                            return nbOfUpcomingCoInsured - coInsuredDeleted.count
                        } else {
                            return nbOfCoInsured - coInsuredDeleted.count
                        }
                    }
                    for _ in 0..<num {
                        filterList.append(CoInsuredModel())
                    }
                    return filterList
                } else if !(upComingList?.isEmpty ?? false) && coInsuredAdded.isEmpty {
                    filterList = upComingList ?? []
                }
            } else if nbOfCoInsured > 0 {
                filterList = existingList
            }
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

struct CoInsuredListType: Hashable, Identifiable {
    var id: String? {
        return coInsured.id
    }
    var coInsured: CoInsuredModel
    var type: StatusPillType?
    var date: String?
    var locallyAdded: Bool
    var isContractOwner: Bool? = nil
}

public struct InsuredPeopleConfig: Codable & Equatable & Hashable {
    var currentAgreementCoInsured: [CoInsuredModel]
    var upcomingAgreementCoInsured: [CoInsuredModel]?
    var contractId: String
    var activeFrom: String?
    var numberOfMissingCoInsured: Int
    let displayName: String
    let preSelectedCoInsuredList: [CoInsuredModel]
    let holderFirstName: String
    let holderLastName: String
    let holderSSN: String?
    var holderFullName: String {
        return holderFirstName + " " + holderLastName
    }

    public init() {
        self.currentAgreementCoInsured = []
        self.upcomingAgreementCoInsured = nil
        self.contractId = ""
        self.activeFrom = nil
        self.numberOfMissingCoInsured = 0
        self.displayName = ""
        self.holderFirstName = ""
        self.holderLastName = ""
        self.holderSSN = nil
        self.preSelectedCoInsuredList = []
    }

    public init(
        contract: Contract
    ) {
        self.currentAgreementCoInsured = contract.currentAgreement?.coInsured ?? []
        self.upcomingAgreementCoInsured = contract.upcomingChangedAgreement?.coInsured
        self.contractId = contract.id
        self.activeFrom = contract.upcomingChangedAgreement?.activeFrom
        self.numberOfMissingCoInsured = contract.nbOfMissingCoInsured
        self.displayName = contract.currentAgreement?.productVariant.displayName ?? ""
        self.holderFirstName = contract.firstName
        self.holderLastName = contract.lastName
        self.holderSSN = contract.ssn

        let store: ContractStore = globalPresentableStoreContainer.get()
        self.preSelectedCoInsuredList = store.state.fetchAllCoInsuredNotInContract(contractId: contractId)
    }
}
