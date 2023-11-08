import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CoInusuredInput: View {
    @State var type: CoInsuredInputType?
    @State var keyboardEnabled: Bool = false
    @PresentableStore var store: ContractStore
    let actionType: CoInsuredAction
    let contractId: String
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel

    public init(
        actionType: CoInsuredAction,
        firstName: String? = "",
        lastName: String? = "",
        SSN: String?,
        contractId: String
    ) {
        self.actionType = actionType
        self.contractId = contractId
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        intentVm = store.intentViewModel
        vm.previousName = vm.fullName
        vm.previousSSN = SSN ?? ""
        vm.SSN = SSN ?? ""
        vm.firstName = firstName ?? ""
        vm.lastName = lastName ?? ""
        vm.SSNError = nil
        vm.showErrorView = false
        intentVm.showErrorView = false
        vm.nameFetchedFromSSN = false
        vm.noSSN = false
    }

    var body: some View {
        if vm.showErrorView || intentVm.showErrorView {
            errorView
        } else {
            mainView
        }
    }

    @ViewBuilder
    var mainView: some View {
        hForm {
            VStack(spacing: 4) {
                if actionType == .delete {
                    deleteCoInsuredFields
                } else {
                    addCoInsuredFields
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        if !(buttonIsDisabled || vm.nameFetchedFromSSN || vm.noSSN) {
                            Task {
                                await vm.getNameFromSSN(SSN: vm.SSN)
                            }
                        } else if actionType == .delete {
                            Task {
                                store.coInsuredViewModel.removeCoInsured(
                                    firstName: vm.firstName,
                                    lastName: vm.lastName,
                                    personalNumber: vm.SSN
                                )
                                if vm.coInsuredDeleted.count > 0 {
                                    await intentVm.getIntent(contractId: contractId, coInsured: vm.completeList)
                                }
                                if !intentVm.showErrorView {
                                    store.send(.coInsuredNavigationAction(action: .deletionSuccess))
                                } else {
                                    // add back
                                    store.coInsuredViewModel.undoDeleted(
                                        firstName: vm.firstName,
                                        lastName: vm.lastName,
                                        personalNumber: vm.SSN
                                    )
                                }
                            }

                        } else if vm.nameFetchedFromSSN || vm.noSSN {
                            Task {
                                if !intentVm.showErrorView {
                                    if actionType == .edit {
                                        store.coInsuredViewModel.editCoInsured(
                                            firstName: vm.firstName,
                                            lastName: vm.lastName,
                                            personalNumber: vm.SSN
                                        )
                                    } else {
                                        store.coInsuredViewModel.addCoInsured(
                                            firstName: vm.firstName,
                                            lastName: vm.lastName,
                                            personalNumber: vm.SSN
                                        )
                                    }
                                    print("list: ", vm.completeList, " count ", vm.completeList.count)
                                    await intentVm.getIntent(contractId: contractId, coInsured: vm.completeList)
                                    if !intentVm.showErrorView {
                                        store.send(.coInsuredNavigationAction(action: .addSuccess))
                                    } else {
                                        store.coInsuredViewModel.removeCoInsured(
                                            firstName: vm.firstName,
                                            lastName: vm.lastName,
                                            personalNumber: vm.SSN
                                        )
                                    }
                                }
                            }
                        }
                    } content: {
                        hText(buttonDisplayText)
                            .transition(.opacity.animation(.easeOut))
                    }
                    .hButtonIsLoading(vm.isLoading || intentVm.isLoading)
                }
                .padding(.top, 12)
                .disabled(buttonIsDisabled && !(actionType == .delete))

                hButton.LargeButton(type: .ghost) {
                    store.send(.coInsuredNavigationAction(action: .dismissEdit))
                } content: {
                    hText(L10n.generalCancelButton)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    var errorView: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)

                VStack {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(vm.SSNError ?? intentVm.errorMessage ?? "")
                        .foregroundColor(hTextColor.secondaryTranslucent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if vm.enterManually {
                    hButton.LargeButton(type: .primary) {
                        vm.showErrorView = false
                        vm.noSSN = true
                        vm.SSN = ""
                    } content: {
                        hText(L10n.coinsuredEnterManuallyButton)
                    }
                } else {
                    hButton.LargeButton(type: .primary) {
                        vm.showErrorView = false
                        intentVm.showErrorView = false
                    } content: {
                        hText(L10n.generalRetry)
                    }
                }
                hButton.LargeButton(type: .ghost) {
                    vm.showErrorView = false
                    intentVm.showErrorView = false
                } content: {
                    hText(L10n.generalCancelButton)
                }

            }
            .padding(16)
        }
    }

    var buttonDisplayText: String {
        if actionType == .delete {
            return L10n.removeConfirmationButton
        } else if vm.nameFetchedFromSSN {
            return L10n.contractAddCoinsured
        } else if Masking(type: .birthDate).isValid(text: vm.SSN) && !vm.noSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return L10n.generalSaveButton
        }
    }

    @ViewBuilder
    var addCoInsuredFields: some View {
        Group {
            if vm.noSSN {
                hSection {
                    hFloatingTextField(
                        masking: Masking(type: .birthDate),
                        value: $vm.SSN,
                        equals: $type,
                        focusValue: .SSN,
                        placeholder: L10n.contractBirthDate
                    )
                }
                .sectionContainerStyle(.transparent)
                .onAppear {
                    vm.nameFetchedFromSSN = false
                }
            } else {
                hSection {
                    hFloatingTextField(
                        masking: Masking(type: .personalNumber12Digits),
                        value: $vm.SSN,
                        equals: $type,
                        focusValue: .SSN,
                        placeholder: L10n.contractPersonalIdentity
                    )
                }
                .disabled(vm.isLoading)
                .sectionContainerStyle(.transparent)
                .onChange(of: vm.SSN) { newValue in
                    vm.nameFetchedFromSSN = false
                }
            }

            if vm.nameFetchedFromSSN || vm.noSSN {
                hSection {
                    HStack(spacing: 4) {
                        hFloatingTextField(
                            masking: Masking(type: .firstName),
                            value: $vm.firstName,
                            equals: $type,
                            focusValue: .firstName,
                            placeholder: L10n.contractFirstName
                        )
                        hFloatingTextField(
                            masking: Masking(type: .lastName),
                            value: $vm.lastName,
                            equals: $type,
                            focusValue: .lastName,
                            placeholder: L10n.contractLastName
                        )
                    }
                }
                .disabled(vm.nameFetchedFromSSN)
                .sectionContainerStyle(.transparent)
            }

            hSection {
                Toggle(isOn: $vm.noSSN.animation(.default)) {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(L10n.contractAddCoinsuredNoSsn, style: .body)
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        vm.noSSN.toggle()
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .sectionContainerStyle(.opaque)
        }
        .hFieldSize(.small)
    }

    @ViewBuilder
    var deleteCoInsuredFields: some View {
        if vm.firstName != "" && vm.lastName != "" && vm.SSN != "" {
            hSection {
                hFloatingField(
                    value: vm.fullName,
                    placeholder: L10n.fullNameText,
                    onTap: {}
                )
            }
            .hFieldTrailingView {
                Image(uiImage: hCoreUIAssets.lockSmall.image)
                    .foregroundColor(hTextColor.secondary)
            }
            .disabled(true)
            .sectionContainerStyle(.transparent)

            hSection {
                hFloatingField(
                    value: vm.SSN,
                    placeholder: L10n.TravelCertificate.personalNumber,
                    onTap: {}
                )
            }
            .hFieldTrailingView {
                Image(uiImage: hCoreUIAssets.lockSmall.image)
                    .foregroundColor(hTextColor.secondary)
            }
            .disabled(true)
            .sectionContainerStyle(.transparent)
        }
    }

    var buttonIsDisabled: Bool {
        var personalNumberValid = false
        if vm.noSSN {
            personalNumberValid = Masking(type: .birthDate).isValid(text: vm.SSN)
            let firstNameValid = Masking(type: .firstName).isValid(text: vm.firstName)
            let lastNameValid = Masking(type: .lastName).isValid(text: vm.lastName)
            if personalNumberValid && firstNameValid && lastNameValid {
                return false
            }
        } else {
            personalNumberValid = Masking(type: .personalNumber12Digits).isValid(text: vm.SSN)
            if personalNumberValid {
                return false
            }
        }
        return true
    }
}

struct CoInusuredInput_Previews: PreviewProvider {
    static var previews: some View {
        CoInusuredInput(actionType: .add, SSN: "", contractId: "")
    }
}

enum CoInsuredInputType: hTextFieldFocusStateCompliant {
    static var last: CoInsuredInputType {
        return CoInsuredInputType.lastName
    }

    var next: CoInsuredInputType? {
        switch self {
        case .SSN:
            return .firstName
        case .firstName:
            return .lastName
        case .lastName:
            return nil
        }
    }

    case firstName
    case lastName
    case SSN
}

public class IntentViewModel: ObservableObject {
    @Published var activationDate = ""
    @Published var currentPremium = MonetaryAmount(amount: "", currency: "")
    @Published var newPremium = MonetaryAmount(amount: "", currency: "")
    @Published var id = ""
    @Published var state = ""
    @Published var isLoading: Bool = false
    @Published var showErrorView = false
    var errorMessage: String?
    @Inject var octopus: hOctopus

    @MainActor
    func getIntent(contractId: String, coInsured: [CoInsuredModel]) async {
        withAnimation {
            self.isLoading = true
        }
        do {
            let data = try await withCheckedThrowingContinuation {
                (
                    continuation: CheckedContinuation<
                        OctopusGraphQL.MidtermChangeIntentCreateMutation.Data.MidtermChangeIntentCreate, Error
                    >
                ) -> Void in
                let coInsuredList = coInsured.map { coIn in
                    OctopusGraphQL.CoInsuredInput(
                        firstName: coIn.firstName,
                        lastName: coIn.lastName,
                        ssn: coIn.formattedSSN,
                        birthdate: coIn.birthDate
                    )
                }
                print("list; ", coInsuredList)
                let coinsuredInput = OctopusGraphQL.MidtermChangeIntentCreateInput(coInsuredInputs: coInsuredList)
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.MidtermChangeIntentCreateMutation(
                            contractId: contractId,
                            input: coinsuredInput
                        )
                    )
                    .onValue { value in
                        continuation.resume(with: .success(value.midtermChangeIntentCreate))
                        if let graphQLError = value.midtermChangeIntentCreate.userError {
                            self.errorMessage = graphQLError.message
                            self.showErrorView = true
                        } else if let intent = value.midtermChangeIntentCreate.intent {
                            self.activationDate = intent.activationDate
                            self.currentPremium = .init(fragment: intent.currentPremium.fragments.moneyFragment)
                            self.newPremium = .init(fragment: intent.newPremium.fragments.moneyFragment)
                            self.id = intent.id
                            self.state = intent.state.rawValue
                        }
                    }
                    .onError { graphQLError in
                        continuation.resume(throwing: graphQLError)
                    }
            }
        } catch let exception {
            withAnimation {
                self.errorMessage = L10n.General.errorBody
                self.showErrorView = true
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}
