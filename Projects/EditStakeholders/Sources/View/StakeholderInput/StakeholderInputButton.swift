import SwiftUI
import hCore
import hCoreUI

public struct StakeholderInputButton: View {
    @ObservedObject var vm: StakeholderInputViewModel
    @ObservedObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @ObservedObject private var intentViewModel: IntentViewModel

    private let stakeholderType: StakeholderType

    init(
        vm: StakeholderInputViewModel,
        editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    ) {
        self.vm = vm
        self.editStakeholdersNavigation = editStakeholdersNavigation
        intentViewModel = editStakeholdersNavigation.intentViewModel
        stakeholderType = editStakeholdersNavigation.stakeholderViewModel.config.stakeholderType
    }

    public var body: some View {
        hSection {
            HStack {
                if vm.actionType == .delete {
                    CoInsuredActionButton(
                        style: .alert,
                        title: L10n.removeConfirmationButton,
                        vm: vm,
                        intentViewModel:
                            intentViewModel,
                        onTap: {
                            await performIntent(for: .delete)
                        }
                    )
                    .colorScheme(.dark)
                } else {
                    CoInsuredActionButton(
                        style: .primary,
                        title: vm.buttonDisplayText(for: stakeholderType),
                        vm: vm,
                        intentViewModel: intentViewModel,
                        onTap: {
                            await vm.handleAddOrEditAction(performIntent: {
                                await performIntent(for: vm.actionType)
                            })
                        }
                    )
                }
            }
        }
        .padding(.top, .padding12)
        .disabled(vm.buttonIsDisabled && !(vm.actionType == .delete))
    }

    var stakeholderToDelete: Stakeholder {
        (vm.personalData.firstName == "" && vm.SSN == "")
            ? .init()
            : .init(
                firstName: vm.personalData.firstName,
                lastName: vm.personalData.lastName,
                SSN: vm.SSN != "" ? vm.SSN : nil,
                birthDate: vm.SSN == "" ? vm.birthday : nil,
                needsMissingInfo: false
            )
    }

    var stakeholderPerformModel: Stakeholder {
        .init(
            firstName: vm.personalData.firstName,
            lastName: vm.personalData.lastName,
            SSN: vm.noSSN ? nil : vm.SSN,
            birthDate: vm.noSSN ? vm.birthday : nil,
            needsMissingInfo: false
        )
    }

    private func performErrorAction(for action: StakeholderAction) {
        if action == .delete {
            editStakeholdersNavigation.stakeholderViewModel.undoDeleted(stakeholderPerformModel)
        } else {
            editStakeholdersNavigation.stakeholderViewModel.removeStakeholder(stakeholderPerformModel)
        }
    }

    private func performIntent(for action: StakeholderAction) async {
        let stakeholderModel: [Stakeholder] = {
            switch action {
            case .add:
                return editStakeholdersNavigation.stakeholderViewModel.listForGettingIntentFor(
                    addStakeholder: stakeholderPerformModel
                )
            case .edit:
                return editStakeholdersNavigation.stakeholderViewModel.listForGettingIntentFor(
                    editStakeholder: stakeholderPerformModel
                )
            case .delete:
                return editStakeholdersNavigation.stakeholderViewModel.listForGettingIntentFor(
                    removedStakeholder: stakeholderToDelete
                )
            }
        }()

        await editStakeholdersNavigation.intentViewModel.getIntent(
            contractId: vm.contractId,
            origin: .stakeholderInput,
            stakeholders: stakeholderModel,
            type: stakeholderType,
        )

        if !editStakeholdersNavigation.intentViewModel.showErrorViewForStakeholderInput {
            switch action {
            case .delete:
                editStakeholdersNavigation.stakeholderViewModel.removeStakeholder(stakeholderToDelete)
            case .edit, .add:
                break
            }
            editStakeholdersNavigation.stakeholderInputModel = nil
        } else {
            performErrorAction(for: action)
        }

        editStakeholdersNavigation.selectStakeholder = nil
    }
}

private struct CoInsuredActionButton: View {
    let style: hButtonConfigurationType
    let title: String
    @ObservedObject var vm: StakeholderInputViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    let onTap: () async -> Void

    init(
        style: hButtonConfigurationType,
        title: String,
        vm: StakeholderInputViewModel,
        intentViewModel: IntentViewModel,
        onTap: @escaping () async -> Void
    ) {
        self.style = style
        self.title = title
        self.vm = vm
        self.intentViewModel = intentViewModel
        self.onTap = onTap
    }

    var body: some View {
        hButton(
            .large,
            style,
            content: .init(title: title),
            {
                Task {
                    await onTap()
                }
            }
        )
        .transition(.opacity.animation(.easeOut))
        .hButtonIsLoading(vm.isLoading || intentViewModel.isLoading)
    }
}

extension StakeholderInputViewModel {
    func buttonDisplayText(for stakeholderType: StakeholderType) -> String {
        if !noSSN, !nameFetchedFromSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return stakeholderType.addButtonTitle
        }
    }

    var buttonIsDisabled: Bool {
        if noSSN {
            let birthdayIsValid = Masking(type: .birthDateCoInsured(minAge: 0)).isValid(text: birthday)
            let firstNameValid = Masking(type: .firstName).isValid(text: personalData.firstName)
            let lastNameValid = Masking(type: .lastName).isValid(text: personalData.lastName)
            if birthdayIsValid, firstNameValid, lastNameValid {
                return false
            }
        } else {
            let masking = Masking(type: .personalNumber(minAge: 0))
            let personalNumberValid = masking.isValid(text: SSN)
            return !personalNumberValid
        }
        return true
    }

    func handleAddOrEditAction(performIntent: @escaping () async -> Void) async {
        if !(buttonIsDisabled || nameFetchedFromSSN || noSSN) {
            await getNameFromSSN(SSN: SSN)
        } else if nameFetchedFromSSN || noSSN {
            await performIntent()
        }
    }
}
