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
                        ContractOwnerField(coInsured: contract.coInsured)
                        hSection {
                            ForEach(contract.coInsured, id: \.self) { coInsured in
                                if !vm.coInsuredDeleted.contains(coInsured) {
                                    CoInsuredField(
                                        coInsured: coInsured,
                                        accessoryView: existingAccessoryView(coInsured: coInsured)
                                    )
                                }
                            }
                        }
                        .sectionContainerStyle(.transparent)

                        hSection {
                            ForEach(vm.coInsuredAdded, id: \.self) { coInsured in
                                CoInsuredField(
                                    coInsured: coInsured,
                                    accessoryView: localAccessoryView(coInsured: coInsured),
                                    includeStatusPill: true
                                )
                            }
                        }
                        .sectionContainerStyle(.transparent)

                        hSection {
                            hButton.LargeButton(type: .secondary) {
                                store.send(
                                    .coInsuredNavigationAction(
                                        action: .openCoInsuredInput(
                                            isDeletion: false,
                                            firstName: nil,
                                            lastName: nil,
                                            personalNumber: nil,
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
                    confirmChangesView
                }
                cancelButton
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
                            isDeletion: true,
                            firstName: coInsured.firstName,
                            lastName: coInsured.lastName,
                            personalNumber: coInsured.SSN,
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
                            isDeletion: true,
                            firstName: coInsured.firstName,
                            lastName: coInsured.lastName,
                            personalNumber: coInsured.SSN,
                            title: L10n.contractRemoveCoinsuredConfirmation,
                            contractId: contractId
                        )
                    )
                )
            }
    }

    var cancelButton: some View {
        hButton.LargeButton(type: .ghost) {
            store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
        } content: {
            hText(L10n.generalCancelButton)
        }
        .padding(.horizontal, 16)
    }

    var confirmChangesView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 2) {
                HStack(spacing: 8) {
                    hText(L10n.contractAddCoinsuredTotal)
                    Spacer()

                    if #available(iOS 16.0, *) {
                        hText("129" + " " + L10n.paymentCurrencyOccurrence)
                            .strikethrough()
                            .foregroundColor(hTextColor.secondary)
                    } else {
                        hText("129" + " " + L10n.paymentCurrencyOccurrence)
                            .foregroundColor(hTextColor.secondary)

                    }
                    hText("159" + " " + L10n.paymentCurrencyOccurrence)
                }
                hText(
                    L10n.contractAddCoinsuredStartsFrom("2023-11-16".localDateToDate?.displayDateDDMMMYYYYFormat ?? ""),
                    style: .footnote
                )
                .foregroundColor(hTextColor.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            LoadingButtonWithContent(ContractStore.self, .postCoInsured) {
                /* TODO: SEND MUTATION */
                store.send(.coInsuredNavigationAction(action: .openCoInsuredProcessScreen(showSuccess: true)))
            } content: {
                hText(L10n.contractAddCoinsuredConfirmChanges)
            }
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

    @Published var coInsuredAdded: [CoInsuredModel] = []
    @Published var coInsuredDeleted: [CoInsuredModel] = []
    @Published var noSSN = false
    @Published var SSNError: Error?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorView: Bool = false
    @Published var enterManually: Bool = false
    @PresentableStore var store: ContractStore
    @Inject var octopus: hOctopus

    var resetCoInsured: Void {
        coInsuredAdded = []
    }

    func addCoInsured(firstName: String, lastName: String, personalNumber: String) {
        coInsuredAdded.append(CoInsuredModel(firstName: firstName, lastName: lastName, SSN: personalNumber))
    }

    func removeCoInsured(firstName: String, lastName: String, personalNumber: String) {
        let removedCoInsured = CoInsuredModel(firstName: firstName, lastName: lastName, SSN: personalNumber)
        if coInsuredAdded.contains(removedCoInsured) {
            if let index = coInsuredAdded.firstIndex(where: {
                ($0.fullName == removedCoInsured.fullName && $0.SSN == removedCoInsured.SSN)
            }) {
                coInsuredAdded.remove(at: index)
            }
        } else {
            coInsuredDeleted.append(CoInsuredModel(firstName: firstName, lastName: lastName, SSN: personalNumber))
        }
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
                self.SSNError = exception
                self.showErrorView = true
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}
