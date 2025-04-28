import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

public struct CoInsuredInputButton: View {
    @ObservedObject var vm: CoInusuredInputViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel
    @ObservedObject var insuredPeopleVm: InsuredPeopleScreenViewModel
    @EnvironmentObject private var router: Router

    init(
        vm: CoInusuredInputViewModel,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel,
        intentViewModel: IntentViewModel,
        insuredPeopleVm: InsuredPeopleScreenViewModel,
    ) {
        self.vm = vm
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.intentViewModel = intentViewModel
        self.insuredPeopleVm = insuredPeopleVm
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
        hButton.LargeButton(type: .alert) {
            Task {
                await intentViewModel.getIntent(
                    contractId: vm.contractId,
                    origin: .coinsuredInput,
                    coInsured: insuredPeopleVm.listForGettingIntentFor(
                        removedCoInsured: coInsuredToDelete
                    )
                )
                if !intentViewModel.showErrorViewForCoInsuredInput {
                    editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(coInsuredToDelete)
                } else {
                    performErrorAction(for: .delete)
                }
                editCoInsuredNavigation.coInsuredInputModel = nil
            }
        } content: {
            hText(L10n.removeConfirmationButton)
                .transition(.opacity.animation(.easeOut))
        }
        .hButtonIsLoading(vm.isLoading || intentViewModel.isLoading)
    }

    private func performErrorAction(for action: CoInsuredAction) {
        let errorModel: CoInsuredModel = .init(
            firstName: vm.personalData.firstName,
            lastName: vm.personalData.lastName,
            SSN: !vm.noSSN ? vm.SSN : nil,
            birthDate: vm.noSSN ? vm.birthday : nil,
            needsMissingInfo: false
        )

        if action == .add {
            editCoInsuredNavigation.coInsuredViewModel.removeCoInsured(errorModel)
        } else {
            editCoInsuredNavigation.coInsuredViewModel.undoDeleted(errorModel)
        }
    }

    private var addCoInsuredButton: some View {
        hButton.LargeButton(type: .primary) {
            if !(buttonIsDisabled || vm.nameFetchedFromSSN || vm.noSSN) {
                Task {
                    await vm.getNameFromSSN(SSN: vm.SSN)
                }
            } else if vm.nameFetchedFromSSN || vm.noSSN {
                sendIntent()
            }
        } content: {
            hText(buttonDisplayText)
                .transition(.opacity.animation(.easeOut))
        }
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
    }

    private func sendIntent() {
        Task {
            if !intentViewModel.showErrorViewForCoInsuredInput {
                vm.actionType == .edit ? await performEditAction() : await performAddAction()

                !intentViewModel.showErrorViewForCoInsuredInput
                    ? router.push(CoInsuredAction.add) : performErrorAction(for: .add)
            }
            editCoInsuredNavigation.selectCoInsured = nil
        }
    }

    func performEditAction() async {
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

        if !editCoInsuredNavigation.intentViewModel
            .showErrorViewForCoInsuredInput
        {
            editCoInsuredNavigation.coInsuredInputModel = nil
        }
    }

    func performAddAction() async {
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
            editCoInsuredNavigation.coInsuredInputModel = nil
        }
    }
}
