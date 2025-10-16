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
        intentViewModel = editCoInsuredNavigation.intentViewModel
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
                        title: vm.buttonDisplayText,
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

    var coInsuredToDelete: CoInsuredModel {
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

    var coInsuredPerformModel: CoInsuredModel {
        .init(
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

    private func performIntent(for action: CoInsuredAction) async {
        let coInsuredModel: [CoInsuredModel] = {
            switch action {
            case .add:
                return editCoInsuredNavigation.coInsuredViewModel.listForGettingIntentFor(
                    addCoInsured: coInsuredPerformModel
                )
            case .edit:
                return editCoInsuredNavigation.coInsuredViewModel.listForGettingIntentFor(
                    editCoInsured: coInsuredPerformModel
                )
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

        if !editCoInsuredNavigation.intentViewModel.showErrorViewForCoInsuredInput {
            switch action {
            case .delete:
                editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(coInsuredToDelete)
            case .edit, .add:
                break
            }
            editCoInsuredNavigation.coInsuredInputModel = nil
        } else {
            performErrorAction(for: action)
        }

        editCoInsuredNavigation.selectCoInsured = nil
    }
}

private struct CoInsuredActionButton: View {
    let style: hButtonConfigurationType
    let title: String
    @ObservedObject var vm: CoInusuredInputViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    let onTap: () async -> Void

    init(
        style: hButtonConfigurationType,
        title: String,
        vm: CoInusuredInputViewModel,
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

extension CoInusuredInputViewModel {
    var buttonDisplayText: String {
        if !noSSN, !nameFetchedFromSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return L10n.contractAddCoinsured
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
