import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectScreen: View {
    let contractId: String
    @ObservedObject var vm: InsuredPeopleScreenViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    let itemPickerConfig: ItemConfig<StakeHolder>
    init(
        contractId: String,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.contractId = contractId
        self.editCoInsuredNavigation = editCoInsuredNavigation
        let vm = editCoInsuredNavigation.coInsuredViewModel
        let alreadyAddedCoinsuredMembers = editCoInsuredNavigation.coInsuredViewModel.config.preSelectedStakeHolders
            .filter {
                !editCoInsuredNavigation.coInsuredViewModel.stakeHoldersAdded.contains($0)
            }
        let intentViewModel = editCoInsuredNavigation.intentViewModel

        itemPickerConfig = .init(
            items:
                alreadyAddedCoinsuredMembers
                .compactMap {
                    (object: $0, displayName: .init(title: $0.fullName ?? ""))
                },
            preSelectedItems: { [] },
            onSelected: { selectedCoinsured in
                if let selectedCoinsured = selectedCoinsured.first {
                    if let object = selectedCoinsured.0 {
                        vm.addCoInsured(
                            .init(
                                firstName: object.firstName,
                                lastName: object.lastName,
                                SSN: object.SSN,
                                birthDate: object.birthDate,
                                needsMissingInfo: false
                            )
                        )
                    }
                    Task {
                        withAnimation {
                            vm.isLoading = true
                        }
                        await intentViewModel.getIntent(
                            contractId: contractId,
                            origin: .coinsuredSelectList,
                            coInsured: vm.completeList(),
                            stakeHolderType: vm.config.stakeHolderType
                        )
                        withAnimation {
                            vm.isLoading = false
                        }
                        if !intentViewModel.showErrorViewForCoInsuredList {
                            editCoInsuredNavigation.selectCoInsured = nil
                        } else {
                            if let object = selectedCoinsured.0 {
                                vm.removeCoInsured(
                                    .init(
                                        firstName: object.firstName,
                                        lastName: object.lastName,
                                        SSN: object.SSN,
                                        birthDate: object.birthDate,
                                        needsMissingInfo: false
                                    )
                                )
                            }
                        }
                    }
                }
            },
            onCancel: {
                editCoInsuredNavigation.selectCoInsured = nil
            }
        )
        self.intentViewModel = intentViewModel
        self.vm = vm
        intentViewModel.errorMessageForCoinsuredList = nil
        intentViewModel.errorMessageForInput = nil
    }

    var body: some View {
        if intentViewModel.showErrorViewForCoInsuredList {
            CoInsuredInputErrorView(
                vm: .init(
                    coInsuredModel: StakeHolder(),
                    actionType: .add,
                    contractId: contractId
                ),
                editCoInsuredNavigation: editCoInsuredNavigation,
                showEnterManuallyButton: false
            )
        } else {
            picker
        }
    }

    var picker: some View {
        ItemPickerScreen<StakeHolder>(
            config: itemPickerConfig
        )
        .hItemPickerBottomAttachedView {
            hButton(
                .large,
                .secondary,
                content: .init(
                    title: L10n.generalAddNew
                ),
                {
                    editCoInsuredNavigation.coInsuredInputModel = .init(
                        actionType: .add,
                        coInsuredModel: .init(),
                        title: editCoInsuredNavigation.coInsuredViewModel.config.stakeHolderType.addButtonTitle,
                        contractId: contractId
                    )
                }
            )
            .disabled(vm.isLoading)
            .hButtonDontShowLoadingWhenDisabled(true)
            .padding(.top, -12)
            .padding(.bottom, -4)
        }
        .hItemPickerAttributes([.singleSelect, .attachToBottom])
        .hFormContentPosition(.compact)
        .hButtonIsLoading(vm.isLoading)
    }
}

#Preview {
    CoInsuredSelectScreen(contractId: "", editCoInsuredNavigation: .init(config: .init(stakeHolderType: .coInsured)))
}
