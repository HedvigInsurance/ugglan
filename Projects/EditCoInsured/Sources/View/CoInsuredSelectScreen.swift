import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectScreen: View {
    let contractId: String
    @State var isLoading = false
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    let alreadyAddedCoinsuredMembers: [CoInsuredModel]
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    public init(
        contractId: String,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.contractId = contractId
        self.editCoInsuredNavigation = editCoInsuredNavigation
        vm = editCoInsuredNavigation.coInsuredViewModel
        alreadyAddedCoinsuredMembers = editCoInsuredNavigation.coInsuredViewModel.config.preSelectedCoInsuredList
            .filter({
                !editCoInsuredNavigation.coInsuredViewModel.coInsuredAdded.contains($0)
            })
        intentViewModel = editCoInsuredNavigation.intentViewModel
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
            config: .init(
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
                                isLoading = true
                            }
                            await intentViewModel.getIntent(
                                contractId: contractId,
                                origin: .coinsuredSelectList,
                                coInsured: vm.completeList()
                            )
                            withAnimation {
                                isLoading = false
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
                },
                singleSelect: true,
                attachToBottom: true
            )
        )
        .hItemPickerBottomAttachedView {
            hButton.LargeButton(type: .ghost) {
                editCoInsuredNavigation.coInsuredInputModel = .init(
                    actionType: .add,
                    coInsuredModel: .init(),
                    title: L10n.contractAddCoinsured,
                    contractId: contractId
                )
            } content: {
                HStack(alignment: .center) {
                    Image(uiImage: hCoreUIAssets.plusSmall.image)
                    hText(L10n.generalAddNew)
                }
            }
            .disabled(isLoading)
            .hButtonDontShowLoadingWhenDisabled(true)
            .padding(.top, -12)
            .padding(.bottom, -4)
        }
        .hButtonIsLoading(isLoading)
    }
}

struct CoInsuredSelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredSelectScreen(contractId: "", editCoInsuredNavigation: .init(config: .init()))
    }
}
