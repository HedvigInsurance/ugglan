import SwiftUI
import hCore
import hCoreUI

public struct CoInsuredInputButton: View {
    @ObservedObject var vm: CoInusuredInputViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: Router
    @ObservedObject private var intentViewModel: IntentViewModel

    init(
        vm: CoInusuredInputViewModel,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.vm = vm
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.intentViewModel = editCoInsuredNavigation.intentViewModel
    }

    public var body: some View {
        hSection {
            HStack {
                if vm.actionType == .delete {
                    deleteCoInsuredButton
                } else {
                    addCoInsuredButton
                }
            }
        }
        .padding(.top, .padding12)
        .disabled(buttonIsDisabled && !(vm.actionType == .delete))
    }

    private var deleteCoInsuredButton: some View {
        hButton(
            .large,
            .alert,
            content: .init(title: L10n.removeConfirmationButton),
            {
                Task {
                    await getIntent(for: .delete)
                }
            }
        )
        .transition(.opacity.animation(.easeOut))
        .hButtonIsLoading(vm.isLoading || intentViewModel.isLoading)
    }

    private var addCoInsuredButton: some View {
        hButton(
            .large,
            .primary,
            content: .init(title: buttonDisplayText),
            {
                if !(buttonIsDisabled || vm.nameFetchedFromSSN || vm.noSSN) {
                    Task {
                        await vm.getNameFromSSN(SSN: vm.SSN)
                    }
                } else if vm.nameFetchedFromSSN || vm.noSSN {
                    Task {
                        await getIntent(for: vm.actionType)
                    }
                }
            }
        )
        .transition(.opacity.animation(.easeOut))
        .hButtonIsLoading(vm.isLoading || intentViewModel.isLoading)
    }

    var buttonDisplayText: String {
        if !vm.noSSN && !vm.nameFetchedFromSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return L10n.contractAddCoinsured
        }
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

    var coInsuredToDelete: CoInsuredModel {
        return (vm.personalData.firstName == "" && vm.SSN == "")
            ? .init()
            : .init(
                firstName: vm.personalData.firstName,
                lastName: vm.personalData.lastName,
                SSN: vm.SSN != "" ? vm.SSN : nil,
                birthDate: vm.SSN == "" ? vm.birthday : nil,
                needsMissingInfo: false
            )
    }

    var coInsuredPerformModel: CoInsuredModel {
        return .init(
            firstName: vm.personalData.firstName,
            lastName: vm.personalData.lastName,
            SSN: vm.noSSN ? nil : vm.SSN,
            birthDate: vm.noSSN ? vm.birthday : nil,
            needsMissingInfo: false
        )
    }

    private func performErrorAction(for action: CoInsuredAction) {
        if action == .delete {
            editCoInsuredNavigation.coInsuredViewModel.undoDeleted(coInsuredPerformModel)
        } else {
            editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(coInsuredPerformModel)
        }
    }

    private func getIntent(for action: CoInsuredAction) async {
        if !editCoInsuredNavigation.intentViewModel.showErrorViewForCoInsuredInput {
            switch action {
            case .delete:
                editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(coInsuredToDelete)
            case .edit:
                editCoInsuredNavigation.coInsuredViewModel.editCoInsured(coInsuredPerformModel)
            case .add:
                break
            }
            editCoInsuredNavigation.coInsuredInputModel = nil
        } else {
            performErrorAction(for: .delete)
        }

        let coInsuredModel: [CoInsuredModel] = {
            switch action {
            case .add:
                return editCoInsuredNavigation.coInsuredViewModel.listForGettingIntentFor(
                    addCoInsured: coInsuredPerformModel
                )
            case .edit:
                return editCoInsuredNavigation.coInsuredViewModel.completeList()
            case .delete:
                return editCoInsuredNavigation.coInsuredViewModel.listForGettingIntentFor(
                    removedCoInsured: coInsuredToDelete
                )
            }
        }()

        await editCoInsuredNavigation.intentViewModel.getIntent(
            contractId: vm.contractId,
            origin: .coinsuredInput,
            coInsured: coInsuredModel
        )
        editCoInsuredNavigation.selectCoInsured = nil
    }
}
