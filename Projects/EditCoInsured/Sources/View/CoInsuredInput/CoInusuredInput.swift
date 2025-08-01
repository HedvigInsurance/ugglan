import Combine
import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct CoInusuredInputScreen: View {
    @ObservedObject var insuredPeopleVm: InsuredPeopleScreenViewModel
    @ObservedObject var vm: CoInusuredInputViewModel
    let title: String
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: Router
    @ObservedObject var intentViewModel: IntentViewModel

    init(
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
            mainView.loading($vm.intentViewState)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(alignment: .center) {
                            ForEach(title.components(separatedBy: "\n"), id: \.self) { title in
                                hText(title)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
        }
    }

    @ViewBuilder
    var mainView: some View {
        hForm {
            VStack(spacing: .padding4) {
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
                CoInsuredInputButton(
                    vm: vm,
                    editCoInsuredNavigation: editCoInsuredNavigation
                )
                cancelButtonView
            }
            .padding(.top, vm.actionType == .delete ? .padding16 : 0)
        }
        .hFormContentPosition(.compact)
    }

    private var cancelButtonView: some View {
        hSection {
            hCancelButton {
                editCoInsuredNavigation.coInsuredInputModel = nil
            }
            .padding(.top, .padding4)
            .padding(.bottom, .padding16)
            .disabled(vm.isLoading || intentViewModel.isLoading)
        }
        .sectionContainerStyle(.transparent)
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
        if vm.personalData.firstName != "", vm.personalData.lastName != "", vm.SSN != "" || vm.birthday != "" {
            Group {
                hSection {
                    hFloatingField(
                        value: vm.personalData.fullname,
                        placeholder: L10n.fullNameText,
                        onTap: {}
                    )
                }
                .hFieldTrailingView {
                    hCoreUIAssets.lock.view
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
                    hCoreUIAssets.lock.view
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
        .onChange(of: vm.SSN) { _ in
            vm.nameFetchedFromSSN = false
        }
    }

    var nameFields: some View {
        hSection {
            HStack(spacing: .padding4) {
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
        CoInsuredInputType.lastName
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
    @Published var intentViewState: ProcessingState = .success
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
        personalData = PersonalData(
            firstName: coInsuredModel.firstName ?? "",
            lastName: coInsuredModel.lastName ?? ""
        )
        SSN = coInsuredModel.SSN ?? ""
        birthday = coInsuredModel.birthDate ?? ""
        self.actionType = actionType
        self.contractId = contractId
        if !(coInsuredModel.birthDate ?? "").isEmpty {
            noSSN = true
            enterManually = true
        }

        if !(coInsuredModel.SSN ?? "").isEmpty {
            nameFetchedFromSSN = true
        }
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
        firstName + " " + lastName
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
            self.viewState = .loading
        }
        do {
            let data = try await service.sendIntent(contractId: contractId, coInsured: coInsured)
            withAnimation {
                self.intent = data
                self.viewState = .success
            }
        } catch let exception {
            withAnimation {
                switch origin {
                case .coinsuredSelectList:
                    self.errorMessageForCoinsuredList = exception.localizedDescription
                    self.viewState = .error(errorMessage: errorMessageForCoinsuredList ?? L10n.generalError)
                case .coinsuredInput:
                    self.errorMessageForInput = exception.localizedDescription
                    self.viewState = .error(errorMessage: errorMessageForInput ?? L10n.generalError)
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
