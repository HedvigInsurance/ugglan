import Combine
import SwiftUI
import hCore
import hCoreUI

struct StakeholderInputScreen: View {
    @ObservedObject var insuredPeopleVm: StakeholderListViewModel
    @ObservedObject var vm: StakeholderInputViewModel
    let title: String
    @ObservedObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    init(
        vm: StakeholderInputViewModel,
        title: String,
        editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    ) {
        self.editStakeholdersNavigation = editStakeholdersNavigation
        insuredPeopleVm = editStakeholdersNavigation.stakeholderViewModel
        self.vm = vm
        self.title = title
        intentViewModel = editStakeholdersNavigation.intentViewModel
        insuredPeopleVm.previousValue = vm.stakeholderModel
    }

    var body: some View {
        Group {
            if showErrorView {
                StakeholderInputErrorView(
                    vm: vm,
                    editStakeholdersNavigation: editStakeholdersNavigation,
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
            intentViewModel.errorMessageForStakeholderList = nil
        }
    }

    var showErrorView: Bool {
        vm.showErrorView(
            inputError: intentViewModel.errorMessageForInput
                ?? intentViewModel.errorMessageForStakeholderList
        )
    }

    var mainView: some View {
        hForm {
            VStack(spacing: .padding4) {
                if vm.actionType == .delete {
                    DeleteStakeholderFields(vm: vm)
                } else {
                    AddStakeholderFieldsView(
                        vm: vm,
                        intentViewModel: intentViewModel
                    )
                }
                infoCardView
                StakeholderInputButton(
                    vm: vm,
                    editStakeholdersNavigation: editStakeholdersNavigation
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
                InfoCard(
                    text: editStakeholdersNavigation.stakeholderViewModel.config.stakeholderType.withoutSsnInfo,
                    type: .attention
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private var cancelButtonView: some View {
        hSection {
            hCancelButton {
                editStakeholdersNavigation.stakeholderInputModel = nil
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
        hFieldTrailingView {
            hCoreUIAssets.lock.view
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }
}

struct AddStakeholderFieldsView: View {
    @ObservedObject var vm: StakeholderInputViewModel
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

struct DeleteStakeholderFields: View {
    @ObservedObject var vm: StakeholderInputViewModel

    var body: some View {
        if vm.personalData.firstName != "", vm.personalData.lastName != "", vm.SSN != "" || vm.birthday != "" {
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

#Preview {
    StakeholderInputScreen(
        vm: .init(stakeholderModel: Stakeholder(), actionType: .add, contractId: ""),
        title: "title",
        editStakeholdersNavigation: .init(config: .init(stakeholderType: .coInsured))
    )
}

enum StakeholderInputType: hTextFieldFocusStateCompliant {
    static var last: StakeholderInputType {
        StakeholderInputType.lastName
    }

    var next: StakeholderInputType? {
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
