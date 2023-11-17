import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct InsuredPeopleScreen: View {
    @PresentableStore var store: ContractStore
    let contractId: String
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel

    public init(
        contractId: String
    ) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        intentVm = store.intentViewModel
        self.contractId = contractId
        vm.resetCoInsured
        vm.existingCoInsured = store.state.contractForId(contractId)?.currentAgreement?.coInsured ?? []
        vm.upcomingCoInsured = store.state.contractForId(contractId)?.upcomingChangedAgreement?.coInsured ?? []
    }

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        state.contractForId(contractId)
                    }
                ) { contract in
                    if let contract = contract {
                        let coInsured = contract.currentAgreement?.coInsured
                        ContractOwnerField(coInsured: coInsured ?? [], contractId: contractId)
                        if let upcomingCoInsured = contract.upcomingChangedAgreement?.coInsured {
                            hSection {
                                ForEach(upcomingCoInsured, id: \.self) { upcomingCoInsured in
                                    if coInsured?.contains(CoInsuredModel()) ?? false {
                                        if !vm.coInsuredDeleted.contains(upcomingCoInsured) {
                                            CoInsuredField(
                                                coInsured: upcomingCoInsured,
                                                accessoryView: existingAccessoryView(coInsured: upcomingCoInsured)
                                            )
                                        }
                                    } else {
                                        
                                        if let index = (coInsured ?? [])
                                            .first(where: {
                                                $0 == upcomingCoInsured
                                            })
                                        {
                                            //not deleted
                                            if vm.coInsuredDeleted.first(where: { deleted in
                                                deleted == upcomingCoInsured
                                            }) == nil {
                                                //remaining
                                                CoInsuredField(
                                                    coInsured: upcomingCoInsured,
                                                    accessoryView: existingAccessoryView(coInsured: upcomingCoInsured)
                                                )
                                            }
                                        } else {
                                            //added
                                            //kolla så att
                                            
                                            if vm.coInsuredDeleted.first(where: {
                                                $0 == upcomingCoInsured
                                            }) == nil {
                                                CoInsuredField(
                                                    coInsured: upcomingCoInsured,
                                                    accessoryView: existingAccessoryView(coInsured: upcomingCoInsured),
                                                    includeStatusPill: StatusPillType.added,
                                                    date: (intentVm.activationDate != "")
                                                    ? intentVm.activationDate
                                                    : contract.upcomingChangedAgreement?.activeFrom
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .sectionContainerStyle(.transparent)

                        } else {
                            hSection {
                                ForEach(coInsured ?? [], id: \.self) { coInsured in
                                    if vm.coInsuredDeleted.first(where: {
                                        $0 == coInsured
                                    }) == nil {
                                        CoInsuredField(
                                            coInsured: coInsured,
                                            accessoryView: existingAccessoryView(coInsured: coInsured)
                                        )
                                    }
                                }
                            }
                            .sectionContainerStyle(.transparent)
                        }

                        // adding locally added ones
                        hSection {
                            ForEach(vm.coInsuredAdded, id: \.self) { coInsured in
                                CoInsuredField(
                                    coInsured: coInsured,
                                    accessoryView: localAccessoryView(coInsured: coInsured),
                                    includeStatusPill: StatusPillType.added,
                                    date: (intentVm.activationDate != "")
                                        ? intentVm.activationDate : contract.upcomingChangedAgreement?.activeFrom
                                )
                            }
                        }
                        .sectionContainerStyle(.transparent)

                        hSection {
                            hButton.LargeButton(type: .secondary) {
                                store.send(
                                    .coInsuredNavigationAction(
                                        action: .openCoInsuredInput(
                                            actionType: .add,
                                            coInsuredModel: CoInsuredModel(),
                                            title: L10n.contractAddCoinsured,
                                            contractId: contractId
                                        )
                                    )
                                )
                            } content: {
                                hText(L10n.contractAddCoinsured)
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                }
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
                            contractId: contractId
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
                            contractId: contractId
                        )
                    )
                )
            }
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
        InsuredPeopleScreen(contractId: "")
    }
}

class InsuredPeopleNewScreenModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var SSN: String = ""
    @Published var previousValue = CoInsuredModel()
    @Published var coInsuredAdded: [CoInsuredModel] = []
    @Published var coInsuredDeleted: [CoInsuredModel] = []
    @Published var existingCoInsured: [CoInsuredModel] = []
    @Published var upcomingCoInsured: [CoInsuredModel] = []
    @Published var noSSN = false
    @Published var SSNError: String?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorView: Bool = false
    @Published var enterManually: Bool = false
    @PresentableStore var store: ContractStore
    @Inject var octopus: hOctopus

    var fullName: String {
        return firstName + " " + lastName
    }

    func completeList(contractId: String) -> [CoInsuredModel] {
        var filterList: [CoInsuredModel] = []
        if !upcomingCoInsured.isEmpty {
            filterList = upcomingCoInsured
        } else {
            let nbOfCoInsured = store.state.contractForId(contractId)?.currentAgreement?.coInsured.count ?? 0
            if existingCoInsured.count == 0 && nbOfCoInsured > 0 {
                if coInsuredDeleted.count > 0 {
                    let num = nbOfCoInsured - coInsuredDeleted.count
                    for _ in 1...num {
                        filterList.append(CoInsuredModel())
                    }
                    return filterList
                }
            } else {
                filterList = existingCoInsured
            }
        }
        return filterList.filter { existing in
            if let index = coInsuredDeleted.first(where: { deleted in
                deleted == existing
            }) {
                return false
            } else {
                return true
            }
        } + coInsuredAdded
    }

    var resetCoInsured: Void {
        coInsuredAdded = []
        coInsuredDeleted = []
        SSNError = nil
    }

    func addCoInsured(_ coInsuredModel: CoInsuredModel) {
        showErrorView = false
        SSNError = nil
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

    @MainActor
    func getNameFromSSN(SSN: String) async {
        withAnimation {
            self.SSNError = nil
            self.showErrorView = false
            self.isLoading = true
        }
        do {
            let data = try await withCheckedThrowingContinuation {
                (
                    continuation: CheckedContinuation<
                        OctopusGraphQL.PersonalInformationQuery.Data.PersonalInformation, Error
                    >
                ) -> Void in
                let SSNInput = OctopusGraphQL.PersonalInformationInput(personalNumber: SSN)
                self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.PersonalInformationQuery(input: SSNInput),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { value in
                        if let data = value.personalInformation {
                            continuation.resume(with: .success(data))
                        }
                    }
                    .onError { graphQLError in
                        continuation.resume(throwing: graphQLError)
                    }
            }
            withAnimation {
                self.firstName = data.firstName
                self.lastName = data.lastName
                self.nameFetchedFromSSN = true
            }

        } catch let exception {
            if let exception = exception as? GraphQLError {
                switch exception {
                case .graphQLError:
                    self.enterManually = true
                case .otherError:
                    self.enterManually = false
                }
            }
            withAnimation {
                if let exception = exception as? GraphQLError {
                    switch exception {
                    case .graphQLError:
                        self.SSNError = exception.localizedDescription
                    case .otherError:
                        self.SSNError = L10n.General.errorBody
                    }
                }
                self.showErrorView = true
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}
