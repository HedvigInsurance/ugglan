import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct InsuredPeopleScreen: View {
    @PresentableStore var store: ContractStore
    let contractId: String
    @ObservedObject var vm: InsuredPeopleNewScreenModel

    public init(
        contractId: String
    ) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
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
                                    if let index = (coInsured ?? [])
                                        .first(where: {
                                            vm.isEqualTo(coInsured: $0, coInsuredCompare: upcomingCoInsured)
                                        })
                                    {
                                        //remaining
                                        CoInsuredField(
                                            coInsured: upcomingCoInsured,
                                            accessoryView: existingAccessoryView(coInsured: upcomingCoInsured)
                                        )
                                    } else {
                                        //added
                                        CoInsuredField(
                                            coInsured: upcomingCoInsured,
                                            accessoryView: existingAccessoryView(coInsured: upcomingCoInsured),
                                            includeStatusPill: StatusPillType.added,
                                            date: contract.upcomingChangedAgreement?.activeFrom?.localDateToDate?
                                                .displayDateDDMMMYYYYFormat
                                        )
                                    }
                                }
                            }
                            .sectionContainerStyle(.transparent)

                        } else {
                            hSection {
                                ForEach(coInsured ?? [], id: \.self) { coInsured in
                                    if vm.coInsuredDeleted.first(where: {
                                        vm.isEqualTo(coInsured: $0, coInsuredCompare: coInsured)
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
                                    date: contract.upcomingChangedAgreement?.activeFrom?.localDateToDate?
                                        .displayDateDDMMMYYYYFormat
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
                                            coInsuredModel: .init(),
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
            .hButtonIsLoading(intentVm.isLoading) /* TODO: CORRECT? */
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

    init() {}

    @Published var firstName = ""
    @Published var lastName = ""
    var fullName: String {
        return firstName + " " + lastName
    }
    func isEqualTo(coInsured: CoInsuredModel, coInsuredCompare: CoInsuredModel) -> Bool {
        return coInsured.fullName == coInsuredCompare.fullName
            && (coInsured.SSN == coInsuredCompare.SSN || coInsured.birthDate == coInsuredCompare.birthDate)
    }
    @Published var SSN: String = ""
    @Published var previousName: String = ""
    @Published var previousSSN: String = ""
    @Published var coInsuredAdded: [CoInsuredModel] = []
    @Published var coInsuredDeleted: [CoInsuredModel] = []
    @Published var existingCoInsured: [CoInsuredModel] = []
    @Published var upcomingCoInsured: [CoInsuredModel] = []

    var completeList: [CoInsuredModel] {
        let filterList: [CoInsuredModel]
        if !upcomingCoInsured.isEmpty {
            filterList = upcomingCoInsured
        } else {
            filterList = existingCoInsured
        }
        return filterList.filter { existing in
            if let index = coInsuredDeleted.first(where: { deleted in
                isEqualTo(coInsured: deleted, coInsuredCompare: existing)
            }) {
                return false
            } else {
                return true
            }
        } + coInsuredAdded
    }

    @Published var noSSN = false
    @Published var SSNError: String?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorView: Bool = false
    @Published var enterManually: Bool = false
    @PresentableStore var store: ContractStore
    @Inject var octopus: hOctopus

    var resetCoInsured: Void {
        coInsuredAdded = []
        coInsuredDeleted = []
        SSNError = nil
    }

    func addCoInsured(_ coInsuredModel: CoInsuredModel) {
        coInsuredAdded.append(coInsuredModel)
    }

    func removeCoInsured(firstName: String, lastName: String, personalNumber: String) {
        var removedCoInsured: CoInsuredModel {
            if personalNumber.count == 6 {
                return CoInsuredModel(
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: personalNumber,
                    needsMissingInfo: false
                )
            } else {
                return CoInsuredModel(
                    firstName: firstName,
                    lastName: lastName,
                    SSN: personalNumber,
                    needsMissingInfo: false
                )
            }
        }
        if let index = coInsuredAdded.firstIndex(where: {
            isEqualTo(coInsured: $0, coInsuredCompare: removedCoInsured)
        }) {
            // delete locally added
            coInsuredAdded.remove(at: index)
        } else {
            if personalNumber.count == 6 {
                coInsuredDeleted.append(
                    CoInsuredModel(
                        firstName: firstName,
                        lastName: lastName,
                        birthDate: personalNumber,
                        needsMissingInfo: false
                    )
                )
            } else {
                coInsuredDeleted.append(
                    CoInsuredModel(
                        firstName: firstName,
                        lastName: lastName,
                        SSN: personalNumber,
                        needsMissingInfo: false
                    )
                )
            }
        }
    }

    func undoDeleted(firstName: String, lastName: String, personalNumber: String) {
        var removedCoInsured: CoInsuredModel {
            if personalNumber.count == 6 {
                return CoInsuredModel(
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: personalNumber,
                    needsMissingInfo: false
                )
            } else {
                return CoInsuredModel(
                    firstName: firstName,
                    lastName: lastName,
                    SSN: personalNumber,
                    needsMissingInfo: false
                )
            }
        }

        if let index = coInsuredDeleted.firstIndex(where: {
            isEqualTo(coInsured: $0, coInsuredCompare: removedCoInsured)
        }) {
            coInsuredDeleted.remove(at: index)
        }
    }

    func editCoInsured(_ coInsuredModel: CoInsuredModel) {
        let previousValue = CoInsuredModel(fullName: previousName, SSN: previousSSN, needsMissingInfo: false)
        if let index = coInsuredAdded.firstIndex(where: {
            ($0.fullName == previousValue.fullName && $0.SSN == previousValue.SSN)
        }) {
            coInsuredAdded.remove(at: index)
        }
        addCoInsured(coInsuredModel)
    }

    @MainActor
    func getNameFromSSN(SSN: String) async {
        withAnimation {
            self.SSNError = nil
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
