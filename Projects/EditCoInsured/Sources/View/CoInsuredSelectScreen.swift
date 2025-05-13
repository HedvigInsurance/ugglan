import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectScreen: View {
    let contractId: String
    @ObservedObject var vm: InsuredPeopleScreenViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    let itemPickerConfig: ItemConfig<CoInsuredModel>
    public init(
        contractId: String,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.contractId = contractId
        self.editCoInsuredNavigation = editCoInsuredNavigation
        let vm = editCoInsuredNavigation.coInsuredViewModel
        let alreadyAddedCoinsuredMembers = editCoInsuredNavigation.coInsuredViewModel.config.preSelectedCoInsuredList
            .filter({
                !editCoInsuredNavigation.coInsuredViewModel.coInsuredAdded.contains($0)
            })
        let intentViewModel = editCoInsuredNavigation.intentViewModel

        itemPickerConfig = .init(
            items: {
                return
                    alreadyAddedCoinsuredMembers
                    .compactMap {
                        ((object: $0, displayName: .init(title: $0.fullName ?? "")))
                    }
            }(),
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
                            coInsured: vm.completeList()
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
                        editCoInsuredNavigation.selectCoInsured = nil
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
                    coInsuredModel: CoInsuredModel(),
                    actionType: .add,
                    contractId: contractId
                ),
                editCoInsuredNavigation: editCoInsuredNavigation
            )
        } else {
            picker
        }
    }

    var picker: some View {
        ItemPickerScreen<CoInsuredModel>(
            config: itemPickerConfig
        )
        .hItemPickerBottomAttachedView {
            hButton(
                .large,
                .ghost,
                content: .init(
                    title: L10n.generalAddNew,
                    buttonImage: .init(
                        image: hCoreUIAssets.plusSmall.view,
                        alignment: .leading
                    )
                ),
                {
                    editCoInsuredNavigation.coInsuredInputModel = .init(
                        actionType: .add,
                        coInsuredModel: .init(),
                        title: L10n.contractAddCoinsured,
                        contractId: contractId
                    )
                }
            )
            .disabled(vm.isLoading)
            .hButtonDontShowLoadingWhenDisabled(true)
            .padding(.top, -12)
            .padding(.bottom, -4)
        }
        .hFieldSize(.large)
        .hItemPickerAttributes([.singleSelect, .attachToBottom])
        .hFormContentPosition(.bottom)
        .hButtonIsLoading(vm.isLoading)
    }
}

struct CoInsuredSelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredSelectScreen(contractId: "", editCoInsuredNavigation: .init(config: .init()))
    }
}
