import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CoInusuredInput: View {
    @ObservedObject var insuredPeopleVm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel
    @PresentableStore var store: EditCoInsuredStore
    @ObservedObject var vm: CoInusuredInputViewModel
    let title: String

    public init(
        vm: CoInusuredInputViewModel,
        title: String
    ) {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        insuredPeopleVm = store.coInsuredViewModel
        intentVm = store.intentViewModel
        self.vm = vm
        self.title = title

        vm.SSNError = nil
        intentVm.errorMessageForInput = nil
        intentVm.errorMessageForCoinsuredList = nil

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
        if let error = vm.SSNError ?? intentVm.errorMessageForInput ?? intentVm.errorMessageForCoinsuredList {
            CoInsuredInputErrorView(vm: vm)
        } else {
            mainView
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(alignment: .center) {
                            ForEach(title.components(separatedBy: "\n"), id: \.self) { title in
                                hText(title)
                            }
                        }
                    }
                }
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
                                            origin: .coinsuredInput,
                                            coInsured: insuredPeopleVm.completeList()
                                        )
                                    }
                                    if !intentVm.showErrorViewForCoInsuredInput {
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
                                        if !intentVm.showErrorViewForCoInsuredInput {
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
                                                origin: .coinsuredInput,
                                                coInsured: insuredPeopleVm.completeList()
                                            )
                                            if !intentVm.showErrorViewForCoInsuredInput {
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
                .disabled(vm.isLoading || intentVm.isLoading)
            }
            .padding(.top, vm.actionType == .delete ? 16 : 0)
        }
        .hDisableScroll
    }

    var buttonDisplayText: String {
        if !vm.noSSN && !vm.nameFetchedFromSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return L10n.contractAddCoinsured
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
        .disabled(vm.isLoading || intentVm.isLoading)
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
            .hFieldLockedState
            .hFieldTrailingView {
                Image(uiImage: hCoreUIAssets.lockSmall.image)
                    .foregroundColor(hTextColor.secondary)
            }
            .disabled(true)
            .sectionContainerStyle(.transparent)

            hSection {
                hFloatingField(
                    value: vm.SSN != "" ? vm.SSN.displayFormatSSN ?? "" : vm.birthday.birtDateDisplayFormat,
                    placeholder: vm.SSN != "" ? L10n.TravelCertificate.personalNumber : L10n.contractBirthDate,
                    onTap: {}
                )
            }
            .hFieldLockedState
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
                selectedDate: vm.birthday.localYYMMDDDateToDate ?? vm.birthday.localDateToDate
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
        CoInusuredInput(
            vm: .init(coInsuredModel: CoInsuredModel(), actionType: .add, contractId: ""),
            title: "title"
        )
    }
}

enum CoInsuredInputType: hTextFieldFocusStateCompliant {
    static var last: CoInsuredInputType {
        return CoInsuredInputType.lastName
    }

    var next: CoInsuredInputType? {
        switch self {
        case .SSN:
            return nil
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

public class CoInusuredInputViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var noSSN = false
    @Published var SSNError: String?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
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

    var showErrorView: Bool {
        SSNError != nil
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
        $noSSN.combineLatest($nameFetchedFromSSN).combineLatest($SSNError)
            //            .delay(for: .milliseconds(0), scheduler: DispatchQueue.main)
            .receive(on: RunLoop.main)
            .sink { _ in
                for i in 0...10 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
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
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var nameFetchedFromSSN: Bool = false
    @Published var enterManually: Bool = false
    @Published var errorMessageForInput: String?
    @Published var errorMessageForCoinsuredList: String?
    var fullName: String {
        return firstName + " " + lastName
    }
    @Inject var octopus: hOctopus

    var showErrorViewForCoInsuredList: Bool {
        errorMessageForCoinsuredList != nil
    }
    var showErrorViewForCoInsuredInput: Bool {
        errorMessageForInput != nil
    }

    @MainActor
    func getIntent(contractId: String, origin: GetIntentOrigin, coInsured: [CoInsuredModel]) async {
        withAnimation {
            self.isLoading = true
            self.errorMessageForInput = nil
            self.errorMessageForCoinsuredList = nil
        }
        do {
            let coInsuredList = coInsured.map { coIn in
                OctopusGraphQL.CoInsuredInput(
                    firstName: GraphQLNullable(optionalValue: coIn.firstName),
                    lastName: GraphQLNullable(optionalValue: coIn.lastName),
                    ssn: GraphQLNullable(optionalValue: coIn.formattedSSN),
                    birthdate: GraphQLNullable(optionalValue: coIn.birthDate?.calculate10DigitBirthDate)
                )
            }
            let coinsuredInput = OctopusGraphQL.MidtermChangeIntentCreateInput(
                coInsuredInputs: GraphQLNullable(optionalValue: coInsuredList)
            )
            let mutation = OctopusGraphQL.MidtermChangeIntentCreateMutation(
                contractId: contractId,
                input: coinsuredInput
            )
            let data = try await octopus.client.perform(mutation: mutation).midtermChangeIntentCreate
            withAnimation {
                if let graphQLError = data.userError {
                    switch origin {
                    case .coinsuredSelectList:
                        self.errorMessageForCoinsuredList = graphQLError.message
                    case .coinsuredInput:
                        self.errorMessageForInput = graphQLError.message
                    }
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
                switch origin {
                case .coinsuredSelectList:
                    self.errorMessageForCoinsuredList = exception.localizedDescription
                case .coinsuredInput:
                    self.errorMessageForInput = exception.localizedDescription
                }
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }

    @MainActor
    func getNameFromSSN(SSN: String) async {
        withAnimation {
            self.isLoading = true
        }
        do {
            let SSNInput = OctopusGraphQL.PersonalInformationInput(personalNumber: SSN)
            let query = OctopusGraphQL.PersonalInformationQuery(input: SSNInput)
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            guard let data = data.personalInformation else {
                throw EditCoInsuredError.error(message: L10n.General.errorBody)
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
                        self.errorMessageForInput = exception.localizedDescription
                    case .otherError:
                        self.errorMessageForInput = L10n.General.errorBody
                    }
                }
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }

    enum GetIntentOrigin {
        case coinsuredSelectList
        case coinsuredInput
    }
}
