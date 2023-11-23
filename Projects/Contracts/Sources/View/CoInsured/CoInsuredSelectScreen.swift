import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectScreen: View {
    let contractId: String
    @State var isLoading = false
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    let alreadyAddedCoinsuredMembers: [CoInsuredModel]

    public init(
        contractId: String
    ) {
        self.contractId = contractId
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        alreadyAddedCoinsuredMembers =
            store.state.fetchAllCoInsuredNotInContract(contractId: contractId)
            .filter({
                !store.coInsuredViewModel.coInsuredAdded.contains($0)
            })
    }

    var body: some View {
        picker
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
                            coInsured: store.coInsuredViewModel.completeList(contractId: contractId)
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
