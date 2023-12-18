import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectScreen: View {
    let contractId: String
    @State var isLoading = false
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel
    let alreadyAddedCoinsuredMembers: [CoInsuredModel]

    public init(
        contractId: String
    ) {
        self.contractId = contractId
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        intentVm = store.intentViewModel
        alreadyAddedCoinsuredMembers = store.coInsuredViewModel.config.preSelectedCoInsuredList.filter({
            !store.coInsuredViewModel.coInsuredAdded.contains($0)
        })
        intentVm.errorMessageForCoinsuredList = nil
        intentVm.errorMessageForInput = nil
    }

    var body: some View {
        if intentVm.showErrorViewForCoInsuredList {
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
                return
                    alreadyAddedCoinsuredMembers
                    .compactMap {
                        ((object: $0, displayName: $0.fullName ?? ""))
                    }
            }(),
            preSelectedItems: { [] },
            onSelected: { selectedCoinsured in
                if let selectedCoinsured = selectedCoinsured.first {
                    let store: EditCoInsuredStore = globalPresentableStoreContainer.get()

                    if let object = selectedCoinsured.0 {
                        store.coInsuredViewModel.addCoInsured(
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
                        await store.intentViewModel.getIntent(
                            contractId: contractId,
                            origin: .coinsuredSelectList,
                            coInsured: store.coInsuredViewModel.completeList()
                        )
                        withAnimation {
                            isLoading = false
                        }
                        if !store.intentViewModel.showErrorViewForCoInsuredList {
                            store.send(.coInsuredNavigationAction(action: .dismissEdit))
                        } else {
                            if let object = selectedCoinsured.0 {
                                store.coInsuredViewModel.removeCoInsured(
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
                let contractStore: EditCoInsuredStore = globalPresentableStoreContainer.get()
                contractStore.send(.coInsuredNavigationAction(action: .dismissEdit))
            },
            singleSelect: true,
            attachToBottom: true
        )
        .hCheckboxPickerBottomAttachedView {
            hButton.LargeButton(type: .ghost) {
                let contractStore: EditCoInsuredStore = globalPresentableStoreContainer.get()
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
