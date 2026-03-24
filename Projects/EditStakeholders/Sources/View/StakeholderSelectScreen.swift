import SwiftUI
import hCore
import hCoreUI

struct StakeholderSelectScreen: View {
    let contractId: String
    @ObservedObject var vm: StakeholderListViewModel
    @ObservedObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    let itemPickerConfig: ItemConfig<Stakeholder>
    init(
        contractId: String,
        editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    ) {
        self.contractId = contractId
        self.editStakeholdersNavigation = editStakeholdersNavigation
        let vm = editStakeholdersNavigation.stakeholderViewModel
        let alreadyAddedCoinsuredMembers = editStakeholdersNavigation.stakeholderViewModel.config
            .preSelectedStakeholders
            .filter {
                !editStakeholdersNavigation.stakeholderViewModel.stakeholdersAdded.contains($0)
            }
        let intentViewModel = editStakeholdersNavigation.intentViewModel

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
                        vm.addStakeholder(
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
                            origin: .stakeholderSelect,
                            stakeholders: vm.completeList(),
                            type: vm.config.stakeholderType
                        )
                        withAnimation {
                            vm.isLoading = false
                        }
                        if !intentViewModel.showErrorViewForStakeholders {
                            editStakeholdersNavigation.selectStakeholder = nil
                        } else {
                            if let object = selectedCoinsured.0 {
                                vm.removeStakeholder(
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
                editStakeholdersNavigation.selectStakeholder = nil
            }
        )
        self.intentViewModel = intentViewModel
        self.vm = vm
        intentViewModel.errorMessageForStakeholders = nil
        intentViewModel.errorMessageForInput = nil
    }

    var body: some View {
        if intentViewModel.showErrorViewForStakeholders {
            StakeholderInputErrorView(
                vm: .init(
                    stakeholderModel: Stakeholder(),
                    actionType: .add,
                    contractId: contractId
                ),
                editStakeholdersNavigation: editStakeholdersNavigation,
                showEnterManuallyButton: false
            )
        } else {
            picker
        }
    }

    var picker: some View {
        ItemPickerScreen<Stakeholder>(
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
                    editStakeholdersNavigation.stakeholderInputModel = .init(
                        actionType: .add,
                        stakeholderModel: .init(),
                        title: editStakeholdersNavigation.stakeholderViewModel.config.stakeholderType.addButtonTitle,
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
    StakeholderSelectScreen(
        contractId: "",
        editStakeholdersNavigation: .init(config: .init(stakeholderType: .coInsured))
    )
}
