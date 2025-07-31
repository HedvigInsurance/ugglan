import Combine
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

    public init(
        vm: CoInusuredInputViewModel,
        title: String,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.insuredPeopleVm = editCoInsuredNavigation.coInsuredViewModel
        self.vm = vm
        self.title = title
        self.intentViewModel = editCoInsuredNavigation.intentViewModel
        insuredPeopleVm.previousValue = vm.coInsuredModel
    }

    var body: some View {
        Group {
            if showErrorView {
                CoInsuredInputErrorView(
                    vm: vm,
                    editCoInsuredNavigation: editCoInsuredNavigation,
                    showEnterManuallyButton: vm.actionType == .add && !vm.noSSN
                )
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
        .onAppear {
            vm.SSNError = nil
            intentViewModel.errorMessageForInput = nil
            intentViewModel.errorMessageForCoinsuredList = nil
        }
    }

    var showErrorView: Bool {
        vm.showErrorView(
            inputError: intentViewModel.errorMessageForInput
                ?? intentViewModel.errorMessageForCoinsuredList
        )
    }

    var mainView: some View {
        hForm {
            VStack(spacing: .padding4) {
                if vm.actionType == .delete {
                    DeleteCoInsuredFields(vm: vm)
                } else {
                    AddCoInsuredFieldsView(vm: vm, intentViewModel: intentViewModel)
                }
                infoCardView
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

    @ViewBuilder
    private var infoCardView: some View {
        if vm.showInfoForMissingSSN {
            hSection {
                InfoCard(text: L10n.coinsuredWithoutSsnInfo, type: .attention)
            }
            .sectionContainerStyle(.transparent)
        }
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
}

extension View {
    func lockTrailingView() -> some View {
        self.hFieldTrailingView {
            hCoreUIAssets.lock.view
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }
}

struct AddCoInsuredFieldsView: View {
    @ObservedObject var vm: CoInusuredInputViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    var body: some View {
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

struct DeleteCoInsuredFields: View {
    @ObservedObject var vm: CoInusuredInputViewModel

    var body: some View {
        if vm.personalData.firstName != "" && vm.personalData.lastName != "" && (vm.SSN != "" || vm.birthday != "") {
            Group {
                nameField
                ssnField
            }
            .hBackgroundOption(option: [.locked])
            .disabled(true)
            .sectionContainerStyle(.transparent)
        }
    }

    private var nameField: some View {
        hSection {
            hFloatingField(
                value: vm.personalData.fullname,
                placeholder: L10n.fullNameText,
                onTap: {}
            )
        }
        .lockTrailingView()
    }

    private var ssnField: some View {
        hSection {
            hFloatingField(
                value: vm.SSN != "" ? vm.SSN.displayFormatSSN ?? "" : vm.birthday.birtDateDisplayFormat,
                placeholder: vm.SSN != "" ? L10n.TravelCertificate.personalNumber : L10n.contractBirthDate,
                onTap: {}
            )
        }
        .lockTrailingView()
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
