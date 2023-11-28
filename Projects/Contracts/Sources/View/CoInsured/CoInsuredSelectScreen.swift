import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectScreen: View {
    let contractId: String
    @State var isLoading = false
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel

    public init(
        contractId: String
    ) {
        self.contractId = contractId
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        intentVm = store.intentViewModel
        intentVm.showErrorView = false
    }

    var body: some View {
        if intentVm.showErrorView {
            CoInsuredInputErrorView(
                vm: .init(
                    coInsuredModel: CoInsuredModel(),
                    actionType: .add,
                    contractId: contractId
                )
            )
        } else {
            picker
        }
    }

    var picker: some View {
        CheckboxPickerScreen<CoInsuredModel>(
            items: {
                let alreadyAddedCoinsuredMembers = vm.config.preSelectedCoInsuredList
                    .compactMap {
                        ((object: $0, displayName: $0.fullName ?? ""))
                    }
                return alreadyAddedCoinsuredMembers
            }(),
            preSelectedItems: { [] },
            onSelected: { selectedCoinsured in
                if let selectedCoinsured = selectedCoinsured.first {
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.coInsuredViewModel.addCoInsured(
                        .init(
                            firstName: selectedCoinsured.firstName,
                            lastName: selectedCoinsured.lastName,
                            SSN: selectedCoinsured.SSN,
                            birthDate: selectedCoinsured.birthDate,
                            needsMissingInfo: false
                        )
                    )
                    Task {
                        withAnimation {
                            isLoading = true
                        }
                        await store.intentViewModel.getIntent(
                            contractId: contractId,
                            coInsured: store.coInsuredViewModel.completeList()
                        )
                        withAnimation {
                            isLoading = false
                        }
                        if !store.intentViewModel.showErrorView {
                            store.send(.coInsuredNavigationAction(action: .dismissEdit))
                        } else {
                            store.coInsuredViewModel.removeCoInsured(
                                .init(
                                    firstName: selectedCoinsured.firstName,
                                    lastName: selectedCoinsured.lastName,
                                    SSN: selectedCoinsured.SSN,
                                    birthDate: selectedCoinsured.birthDate,
                                    needsMissingInfo: false
                                )
                            )
                        }
                    }
                }
            },
            onCancel: {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.coInsuredNavigationAction(action: .dismissEdit))
            },
            singleSelect: true,
            attachToBottom: true
        )
        .hCheckboxPickerBottomAttachedView {
            hButton.LargeButton(type: .ghost) {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            actionType: .add,
                            coInsuredModel: .init(),
                            title: L10n.contractAddCoinsured,
                            contractId: contractId
                        )
                    )
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
        CoInsuredSelectScreen(contractId: "")
    }
}
