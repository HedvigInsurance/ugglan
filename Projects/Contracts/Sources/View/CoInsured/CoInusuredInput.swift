import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CoInusuredInput: View {
    @ObservedObject var insuredPeopleVm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel
    @PresentableStore var store: ContractStore
    @ObservedObject var vm: CoInusuredInputViewModel

    public init(
        vm: CoInusuredInputViewModel
    ) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        insuredPeopleVm = store.coInsuredViewModel
        intentVm = store.intentViewModel
        self.vm = vm

        vm.showErrorView = false
        intentVm.showErrorView = false

        if vm.SSN != "" {
            vm.noSSN = false
            insuredPeopleVm.previousValue = CoInsuredModel(
                firstName: vm.firstName,
                lastName: vm.lastName,
                SSN: vm.SSN,
                needsMissingInfo: false
            )
        } else if vm.birthday != "" {
            vm.noSSN = true
            insuredPeopleVm.previousValue = CoInsuredModel(
                firstName: vm.firstName,
                lastName: vm.lastName,
                birthDate: vm.birthday,
                needsMissingInfo: false
            )
        }
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
                if vm.actionType == .delete {
                    deleteCoInsuredFields
                } else {
                    addCoInsuredFields
                }
                hSection {
                    HStack {
                        if vm.actionType == .delete {
                            hButton.LargeButton(type: .alert) {
                                Task {
                                    if vm.firstName == "" && vm.SSN == "" {
                                        store.coInsuredViewModel.removeCoInsured(.init())
                                    } else if vm.SSN != "" {
                                        store.coInsuredViewModel.removeCoInsured(
                                            .init(
                                                firstName: vm.firstName,
                                                lastName: vm.lastName,
                                                SSN: vm.SSN,
                                                needsMissingInfo: false
                                            )
                                        )
                                    } else {
                                        store.coInsuredViewModel.removeCoInsured(
                                            .init(
                                                firstName: vm.firstName,
                                                lastName: vm.lastName,
                                                birthDate: vm.birthday,
                                                needsMissingInfo: false
                                            )
                                        )
                                    }
                                    if insuredPeopleVm.coInsuredDeleted.count > 0 {
                                        await intentVm.getIntent(
                                            contractId: vm.contractId,
                                            coInsured: insuredPeopleVm.completeList(contractId: vm.contractId)
                                        )
                                    }
                                    if !intentVm.showErrorView {
                                        store.send(.coInsuredNavigationAction(action: .deletionSuccess))
                                    } else {
                                        // add back
                                        if vm.noSSN {
                                            store.coInsuredViewModel.undoDeleted(
                                                .init(
                                                    firstName: vm.firstName,
                                                    lastName: vm.lastName,
                                                    birthDate: vm.birthday,
                                                    needsMissingInfo: false
                                                )
                                            )
                                        } else {
                                            store.coInsuredViewModel.undoDeleted(
                                                .init(
                                                    firstName: vm.firstName,
                                                    lastName: vm.lastName,
                                                    SSN: vm.SSN,
                                                    needsMissingInfo: false
                                                )
                                            )
                                        }
                                    }
                                }
                            } content: {
                                hText(L10n.removeConfirmationButton)
                                    .transition(.opacity.animation(.easeOut))
                            }
                            .hButtonIsLoading(vm.isLoading || intentVm.isLoading)
                        } else {
                            hButton.LargeButton(type: .primary) {
                                if !(buttonIsDisabled || vm.nameFetchedFromSSN || vm.noSSN) {
                                    Task {
                                        await vm.getNameFromSSN(SSN: vm.SSN)
                                    }
                                } else if vm.nameFetchedFromSSN || vm.noSSN {
                                    Task {
                                        if !intentVm.showErrorView {
                                            if vm.actionType == .edit {
                                                if vm.noSSN {
                                                    store.coInsuredViewModel.editCoInsured(
                                                        .init(
                                                            firstName: vm.firstName,
                                                            lastName: vm.lastName,
                                                            birthDate: vm.birthday,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                } else {
                                                    store.coInsuredViewModel.editCoInsured(
                                                        .init(
                                                            firstName: vm.firstName,
                                                            lastName: vm.lastName,
                                                            SSN: vm.SSN,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                }
                                            } else {
                                                if vm.noSSN {
                                                    store.coInsuredViewModel.addCoInsured(
                                                        .init(
                                                            firstName: vm.firstName,
                                                            lastName: vm.lastName,
                                                            birthDate: vm.birthday,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                } else {
                                                    store.coInsuredViewModel.addCoInsured(
                                                        .init(
                                                            firstName: vm.firstName,
                                                            lastName: vm.lastName,
                                                            SSN: vm.SSN,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                }
                                            }
                                            await intentVm.getIntent(
                                                contractId: vm.contractId,
                                                coInsured: insuredPeopleVm.completeList(contractId: vm.contractId)
                                            )
                                            if !intentVm.showErrorView {
                                                store.send(.coInsuredNavigationAction(action: .addSuccess))
                                            } else {
                                                if vm.noSSN {
                                                    store.coInsuredViewModel.removeCoInsured(
                                                        .init(
                                                            firstName: vm.firstName,
                                                            lastName: vm.lastName,
                                                            birthDate: vm.birthday,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                } else {
                                                    store.coInsuredViewModel.removeCoInsured(
                                                        .init(
                                                            firstName: vm.firstName,
                                                            lastName: vm.lastName,
                                                            SSN: vm.SSN,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                }

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
                    }
                }
                .padding(.top, 12)
                .disabled(buttonIsDisabled && !(vm.actionType == .delete))

                hButton.LargeButton(type: .ghost) {
                    store.send(.coInsuredNavigationAction(action: .dismissEdit))
                } content: {
                    hText(L10n.generalCancelButton)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 16)
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
        if vm.nameFetchedFromSSN {
            return L10n.contractAddCoinsured
        } else if Masking(type: .personalNumberCoInsured).isValid(text: vm.SSN) && !vm.noSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return L10n.generalSaveButton
        }
    }

    @ViewBuilder
    var addCoInsuredFields: some View {
        Group {
            if vm.noSSN {
                datePickerField
            } else {
                ssnField
            }
            if vm.nameFetchedFromSSN || vm.noSSN {
                nameFields
            }
            toggleField
        }
        .hFieldSize(.small)
    }

    @ViewBuilder
    var deleteCoInsuredFields: some View {
        if vm.firstName != "" && vm.lastName != "" && (vm.SSN != "" || vm.birthday != "") {
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
                    value: vm.SSN != "" ? vm.SSN : vm.birthday.birtDateDisplayFormat,
                    placeholder: vm.SSN != "" ? L10n.TravelCertificate.personalNumber : L10n.contractBirthDate,
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

    var datePickerField: some View {
        hSection {
            hDatePickerField(
                config: .init(
                    maxDate: Date(),
                    initialySelectedValue: Date(timeInterval: -60 * 60 * 24 * 365 * 20, since: Date()),
                    placeholder: L10n.contractBirthDate,
                    title: L10n.contractBirthDate,
                    showAsList: true,
                    dateFormatter: .birthDate
                ),
                selectedDate: vm.birthday.localYYMMDDDateToDate
            ) { date in
                vm.birthday = date.displayDateYYMMDDFormat ?? ""
            }
        }
        .sectionContainerStyle(.transparent)
        .onAppear {
            vm.nameFetchedFromSSN = false
        }
    }

    var ssnField: some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .personalNumber),
                value: $vm.SSN,
                equals: $vm.type,
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

    var nameFields: some View {
        hSection {
            HStack(spacing: 4) {
                hFloatingTextField(
                    masking: Masking(type: .firstName),
                    value: $vm.firstName,
                    equals: $vm.type,
                    focusValue: .firstName,
                    placeholder: L10n.contractFirstName
                )
                hFloatingTextField(
                    masking: Masking(type: .lastName),
                    value: $vm.lastName,
                    equals: $vm.type,
                    focusValue: .lastName,
                    placeholder: L10n.contractLastName
                )
            }
        }
        .disabled(vm.nameFetchedFromSSN)
        .hWithoutDisabledColor
        .sectionContainerStyle(.transparent)
    }

    var toggleField: some View {
        hSection {
            Toggle(isOn: $vm.noSSN.animation(.default)) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.contractAddCoinsuredNoSsn, style: .body)
                        .foregroundColor(hTextColor.secondary)
                }
            }
            .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
            .contentShape(Rectangle())
            .onChange(
                of: vm.noSSN,
                perform: { newValue in
                    vm.SSN = ""
                }
            )
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .frame(height: 56)
        .sectionContainerStyle(.opaque)
    }

    var buttonIsDisabled: Bool {
        if vm.noSSN {
            let birthdayIsValid = Masking(type: .birthDateCoInsured).isValid(text: vm.birthday)
            let firstNameValid = Masking(type: .firstName).isValid(text: vm.firstName)
            let lastNameValid = Masking(type: .lastName).isValid(text: vm.lastName)
            if birthdayIsValid && firstNameValid && lastNameValid {
                return false
            }
        } else {
            let personalNumberValid = Masking(type: .personalNumberCoInsured).isValid(text: vm.SSN)
            if personalNumberValid {
                return false
            }
        }
        return true
    }
}

struct CoInusuredInput_Previews: PreviewProvider {
    static var previews: some View {
        CoInusuredInput(vm: .init(coInsuredModel: CoInsuredModel(), actionType: .add, contractId: ""))
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
        case .birthDay:
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
    case birthDay
}

class CoInusuredInputViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var noSSN = false
    @Published var SSNError: String?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorView: Bool = false
    @Published var enterManually: Bool = false
    @Published var SSN: String
    @Published var birthday: String
    @Published var type: CoInsuredInputType?
    @Published var actionType: CoInsuredAction
    let contractId: String
    let coInsuredModel: CoInsuredModel?
    @Inject var octopus: hOctopus

    var fullName: String {
        return firstName + " " + lastName
    }
    var cancellables = Set<AnyCancellable>()
    init(
        coInsuredModel: CoInsuredModel,
        actionType: CoInsuredAction,
        contractId: String
    ) {
        self.coInsuredModel = coInsuredModel
        self.firstName = coInsuredModel.firstName ?? ""
        self.lastName = coInsuredModel.lastName ?? ""
        self.SSN = coInsuredModel.SSN ?? ""
        self.birthday = coInsuredModel.birthDate ?? ""
        self.actionType = actionType
        self.contractId = contractId
        if !(coInsuredModel.birthDate ?? "").isEmpty {
            noSSN = true
            enterManually = true
        }

        if !(coInsuredModel.SSN ?? "").isEmpty {
            nameFetchedFromSSN = true
        }
        $noSSN.combineLatest($nameFetchedFromSSN)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .receive(on: RunLoop.main)
            .sink { _ in
                if #available(iOS 15.0, *) {
                    if #available(iOS 16.0, *) {
                        UIApplication.shared.getTopViewController()?.sheetPresentationController?
                            .animateChanges {
                                UIApplication.shared.getTopViewController()?.sheetPresentationController?
                                    .invalidateDetents()
                            }
                    } else {
                        UIApplication.shared.getTopViewController()?.sheetPresentationController?
                            .animateChanges {

                            }
                    }
                }
            }
            .store(in: &cancellables)
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
            self.errorMessage = nil
            self.showErrorView = false
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
                        birthdate: coIn.birthDate?.calculate10DigitBirthDate
                    )
                }
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
                    }
                    .onError { graphQLError in
                        continuation.resume(throwing: graphQLError)
                    }
            }
            withAnimation {
                if let graphQLError = data.userError {
                    self.errorMessage = graphQLError.message
                    self.showErrorView = true
                } else if let intent = data.intent {
                    self.activationDate = intent.activationDate
                    self.currentPremium = .init(fragment: intent.currentPremium.fragments.moneyFragment)
                    self.newPremium = .init(fragment: intent.newPremium.fragments.moneyFragment)
                    self.id = intent.id
                    self.state = intent.state.rawValue
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
