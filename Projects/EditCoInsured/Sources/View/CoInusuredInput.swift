import Combine
import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CoInusuredInputScreen: View {
    @ObservedObject var insuredPeopleVm: InsuredPeopleNewScreenModel
    @ObservedObject var vm: CoInusuredInputViewModel
    let title: String
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: Router
    @ObservedObject var intentViewModel: IntentViewModel
    public init(
        vm: CoInusuredInputViewModel,
        title: String,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        insuredPeopleVm = editCoInsuredNavigation.coInsuredViewModel
        self.vm = vm
        self.title = title

        vm.SSNError = nil
        intentViewModel = editCoInsuredNavigation.intentViewModel
        intentViewModel.errorMessageForInput = nil
        intentViewModel.errorMessageForCoinsuredList = nil

        if vm.SSN != "" {
            vm.noSSN = false
            insuredPeopleVm.previousValue = CoInsuredModel(
                firstName: vm.personalData.firstName,
                lastName: vm.personalData.lastName,
                SSN: vm.SSN,
                needsMissingInfo: false
            )
        } else if vm.birthday != "" {
            vm.noSSN = true
            insuredPeopleVm.previousValue = CoInsuredModel(
                firstName: vm.personalData.firstName,
                lastName: vm.personalData.lastName,
                birthDate: vm.birthday,
                needsMissingInfo: false
            )
        }
    }

    var body: some View {
        if (vm.SSNError ?? intentViewModel.errorMessageForInput
            ?? intentViewModel.errorMessageForCoinsuredList) != nil
        {
            CoInsuredInputErrorView(vm: vm, editCoInsuredNavigation: editCoInsuredNavigation)
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
                if vm.showInfoForMissingSSN {
                    hSection {
                        InfoCard(text: L10n.coinsuredWithoutSsnInfo, type: .attention)
                    }
                    .sectionContainerStyle(.transparent)
                }
                hSection {
                    HStack {
                        if vm.actionType == .delete {
                            hButton.LargeButton(type: .alert) {
                                Task {
                                    let coInsuredToDelete: CoInsuredModel = {
                                        if vm.personalData.firstName == "" && vm.SSN == "" {
                                            return .init()
                                        } else if vm.SSN != "" {
                                            return .init(
                                                firstName: vm.personalData.firstName,
                                                lastName: vm.personalData.lastName,
                                                SSN: vm.SSN,
                                                needsMissingInfo: false
                                            )
                                        } else {
                                            return .init(
                                                firstName: vm.personalData.firstName,
                                                lastName: vm.personalData.lastName,
                                                birthDate: vm.birthday,
                                                needsMissingInfo: false
                                            )
                                        }
                                    }()
                                    await intentViewModel.getIntent(
                                        contractId: vm.contractId,
                                        origin: .coinsuredInput,
                                        coInsured: insuredPeopleVm.listForGettingIntentFor(
                                            removedCoInsured: coInsuredToDelete
                                        )
                                    )
                                    if !intentViewModel.showErrorViewForCoInsuredInput {
                                        editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(coInsuredToDelete)
                                        router.push(CoInsuredAction.delete)
                                    } else {
                                        // add back
                                        if vm.noSSN {
                                            editCoInsuredNavigation.coInsuredViewModel.undoDeleted(
                                                .init(
                                                    firstName: vm.personalData.firstName,
                                                    lastName: vm.personalData.lastName,
                                                    birthDate: vm.birthday,
                                                    needsMissingInfo: false
                                                )
                                            )
                                        } else {
                                            editCoInsuredNavigation.coInsuredViewModel.undoDeleted(
                                                .init(
                                                    firstName: vm.personalData.firstName,
                                                    lastName: vm.personalData.lastName,
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
                            .hButtonIsLoading(vm.isLoading || intentViewModel.isLoading)
                        } else {
                            hButton.LargeButton(type: .primary) {
                                if !(buttonIsDisabled || vm.nameFetchedFromSSN || vm.noSSN) {
                                    Task {
                                        await vm.getNameFromSSN(SSN: vm.SSN)
                                    }
                                } else if vm.nameFetchedFromSSN || vm.noSSN {
                                    Task {
                                        if !intentViewModel.showErrorViewForCoInsuredInput {
                                            if vm.actionType == .edit {
                                                if vm.noSSN {
                                                    editCoInsuredNavigation.coInsuredViewModel.editCoInsured(
                                                        .init(
                                                            firstName: vm.personalData.firstName,
                                                            lastName: vm.personalData.lastName,
                                                            birthDate: vm.birthday,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                } else {
                                                    editCoInsuredNavigation.coInsuredViewModel.editCoInsured(
                                                        .init(
                                                            firstName: vm.personalData.firstName,
                                                            lastName: vm.personalData.lastName,
                                                            SSN: vm.SSN,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                }
                                                await intentViewModel.getIntent(
                                                    contractId: vm.contractId,
                                                    origin: .coinsuredInput,
                                                    coInsured: insuredPeopleVm.completeList()
                                                )
                                            } else {
                                                let coInsuredToAdd: CoInsuredModel = {
                                                    if vm.noSSN {
                                                        return .init(
                                                            firstName: vm.personalData.firstName,
                                                            lastName: vm.personalData.lastName,
                                                            birthDate: vm.birthday,
                                                            needsMissingInfo: false
                                                        )
                                                    } else {
                                                        return .init(
                                                            firstName: vm.personalData.firstName,
                                                            lastName: vm.personalData.lastName,
                                                            SSN: vm.SSN,
                                                            needsMissingInfo: false
                                                        )
                                                    }
                                                }()

                                                await intentViewModel.getIntent(
                                                    contractId: vm.contractId,
                                                    origin: .coinsuredInput,
                                                    coInsured: insuredPeopleVm.listForGettingIntentFor(
                                                        addCoInsured: coInsuredToAdd
                                                    )
                                                )
                                                if !editCoInsuredNavigation.intentViewModel
                                                    .showErrorViewForCoInsuredInput
                                                {
                                                    insuredPeopleVm.addCoInsured(coInsuredToAdd)
                                                }
                                            }

                                            if !intentViewModel.showErrorViewForCoInsuredInput {
                                                router.push(CoInsuredAction.add)
                                            } else {
                                                if vm.noSSN {
                                                    editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(
                                                        .init(
                                                            firstName: vm.personalData.firstName,
                                                            lastName: vm.personalData.lastName,
                                                            birthDate: vm.birthday,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                } else {
                                                    editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(
                                                        .init(
                                                            firstName: vm.personalData.firstName,
                                                            lastName: vm.personalData.lastName,
                                                            SSN: vm.SSN,
                                                            needsMissingInfo: false
                                                        )
                                                    )
                                                }

                                            }
                                        }
                                        editCoInsuredNavigation.selectCoInsured = nil
                                    }
                                }
                            } content: {
                                hText(buttonDisplayText)
                                    .transition(.opacity.animation(.easeOut))
                            }
                            .hButtonIsLoading(vm.isLoading || intentViewModel.isLoading)
                        }
                    }
                }
                .padding(.top, .padding12)
                .disabled(buttonIsDisabled && !(vm.actionType == .delete))

                hSection {
                    hButton.LargeButton(type: .ghost) {
                        editCoInsuredNavigation.coInsuredInputModel = nil
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                    .padding(.top, .padding4)
                    .padding(.bottom, .padding16)
                    .disabled(vm.isLoading || intentViewModel.isLoading)
                }
                .sectionContainerStyle(.transparent)
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
        .disabled(vm.isLoading || intentViewModel.isLoading)
    }

    @ViewBuilder
    var deleteCoInsuredFields: some View {
        if vm.personalData.firstName != "" && vm.personalData.lastName != "" && (vm.SSN != "" || vm.birthday != "") {
            Group {
                hSection {
                    hFloatingField(
                        value: vm.personalData.fullname,
                        placeholder: L10n.fullNameText,
                        onTap: {}
                    )
                }
                .hFieldTrailingView {
                    Image(uiImage: hCoreUIAssets.lock.image)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }

                hSection {
                    hFloatingField(
                        value: vm.SSN != "" ? vm.SSN.displayFormatSSN ?? "" : vm.birthday.birtDateDisplayFormat,
                        placeholder: vm.SSN != "" ? L10n.TravelCertificate.personalNumber : L10n.contractBirthDate,
                        onTap: {}
                    )
                }
                .hFieldTrailingView {
                    Image(uiImage: hCoreUIAssets.lock.image)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .hBackgroundOption(option: [.locked])
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
                selectedDate: vm.birthday.localBirthDateStringToDate ?? vm.birthday.localDateToDate
            ) { date in
                vm.birthday = date.localBirthDateString
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
                masking: Masking(type: .personalNumber(minAge: 0)),
                value: $vm.SSN,
                equals: $vm.type,
                focusValue: .SSN,
                placeholder: L10n.contractPersonalIdentity,
                textFieldPlaceholder: L10n.editCoinsuredSsnPlaceholder
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
                    value: $vm.personalData.firstName,
                    equals: $vm.type,
                    focusValue: .firstName,
                    placeholder: L10n.contractFirstName
                )
                hFloatingTextField(
                    masking: Masking(type: .lastName),
                    value: $vm.personalData.lastName,
                    equals: $vm.type,
                    focusValue: .lastName,
                    placeholder: L10n.contractLastName
                )
            }
        }
        .disabled(vm.nameFetchedFromSSN)
        .hBackgroundOption(option: [.withoutDisabled])
        .sectionContainerStyle(.transparent)
    }

    var toggleField: some View {
        CheckboxToggleView(
            title: L10n.contractAddCoinsuredNoSsn,
            isOn: $vm.noSSN
        )
        .onChange(
            of: vm.noSSN,
            perform: { value in
                vm.SSN = ""
                if !value {
                    withAnimation {
                        vm.showInfoForMissingSSN = false
                    }
                }
            }
        )
    }

    var buttonIsDisabled: Bool {
        if vm.noSSN {
            let birthdayIsValid = Masking(type: .birthDateCoInsured(minAge: 0)).isValid(text: vm.birthday)
            let firstNameValid = Masking(type: .firstName).isValid(text: vm.personalData.firstName)
            let lastNameValid = Masking(type: .lastName).isValid(text: vm.personalData.lastName)
            if birthdayIsValid && firstNameValid && lastNameValid {
                return false
            }
        } else {
            let masking = Masking(type: .personalNumber(minAge: 0))
            let personalNumberValid = masking.isValid(text: vm.SSN)
            return !personalNumberValid
        }
        return true
    }
}

struct CoInusuredInput_Previews: PreviewProvider {
    static var previews: some View {
        CoInusuredInputScreen(
            vm: .init(coInsuredModel: CoInsuredModel(), actionType: .add, contractId: ""),
            title: "title",
            editCoInsuredNavigation: .init(config: .init())
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

@MainActor
public class CoInusuredInputViewModel: ObservableObject {
    @Published var personalData: PersonalData
    @Published var noSSN = false
    @Published var SSNError: String?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
    @Published var enterManually: Bool = false
    @Published var showInfoForMissingSSN = false
    @Published var SSN: String
    @Published var birthday: String
    @Published var type: CoInsuredInputType?
    @Published var actionType: CoInsuredAction
    let contractId: String
    let coInsuredModel: CoInsuredModel?
    var editCoInsuredService = EditCoInsuredService()

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
        self.personalData = PersonalData(
            firstName: coInsuredModel.firstName ?? "",
            lastName: coInsuredModel.lastName ?? ""
        )
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
            .receive(on: RunLoop.main)
            .sink { _ in
                for i in 0...10 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
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
            .store(in: &cancellables)
    }

    @MainActor
    func getNameFromSSN(SSN: String) async {
        withAnimation {
            self.SSNError = nil
            self.isLoading = true
        }
        do {
            let data = try await editCoInsuredService.getPersonalInformation(SSN: SSN)
            withAnimation {
                if let data = data {
                    self.personalData = data
                    self.nameFetchedFromSSN = true
                }
            }
        } catch let exception {
            if let exception = exception as? EditCoInsuredError {
                switch exception {
                case .missingSSN:
                    withAnimation {
                        self.noSSN = true
                        self.enterManually = true
                        self.showInfoForMissingSSN = true
                    }
                case .otherError, .serviceError:
                    self.enterManually = false
                    withAnimation {
                        self.SSNError = exception.localizedDescription
                    }
                }
            } else {
                withAnimation {
                    self.SSNError = exception.localizedDescription
                }
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}

@MainActor
public class IntentViewModel: ObservableObject {
    @Published var intent = Intent(
        activationDate: "",
        currentPremium: MonetaryAmount(amount: 0, currency: ""),
        newPremium: MonetaryAmount(amount: 0, currency: ""),
        id: "",
        state: ""
    )
    @Published var isLoading: Bool = false
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var nameFetchedFromSSN: Bool = false
    @Published var enterManually: Bool = false
    @Published var errorMessageForInput: String?
    @Published var errorMessageForCoinsuredList: String?
    @Published var viewState: ProcessingState = .loading

    var fullName: String {
        return firstName + " " + lastName
    }
    var service = EditCoInsuredService()

    var showErrorViewForCoInsuredList: Bool {
        errorMessageForCoinsuredList != nil
    }
    var showErrorViewForCoInsuredInput: Bool {
        errorMessageForInput != nil
    }

    var contractId: String?

    @MainActor
    func getIntent(contractId: String, origin: GetIntentOrigin, coInsured: [CoInsuredModel]) async {
        self.contractId = contractId
        withAnimation {
            self.isLoading = true
            self.errorMessageForInput = nil
            self.errorMessageForCoinsuredList = nil
        }
        do {
            let data = try await service.sendIntent(contractId: contractId, coInsured: coInsured)
            withAnimation {
                self.intent = data
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

    enum GetIntentOrigin {
        case coinsuredSelectList
        case coinsuredInput
    }

    @MainActor
    func performCoInsuredChanges(commitId: String) async {
        withAnimation {
            viewState = .loading
            self.isLoading = true
        }
        do {
            try await service.sendMidtermChangeIntentCommit(commitId: commitId)
            withAnimation {
                self.viewState = .success
            }
            AskForRating().askForReview()
        } catch let exception {
            withAnimation {
                viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}
