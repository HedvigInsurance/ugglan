import Presentation
import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleNewScreen: View {
    @PresentableStore var store: ContractStore
    let contractId: String
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @ObservedObject var intentVm: IntentViewModel

    public init(
        contractId: String
    ) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        intentVm = store.intentViewModel
        self.contractId = contractId
        vm.resetCoInsured
    }

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        state.contractForId(contractId)
                    }
                ) { contract in
                    if let contract = contract {
                        if let coInsured = contract.currentAgreement?.coInsured {
                            ContractOwnerField(coInsured: coInsured, contractId: contractId)
                        }

                        hSection(vm.coInsuredAdded, id: \.self) { localCoInsured in
                            CoInsuredField(
                                coInsured: localCoInsured,
                                accessoryView: localAccessoryView(coInsured: localCoInsured)
                            )
                        }
                        .sectionContainerStyle(.transparent)

                        let nbOfMissingCoInsured = contract.nbOfMissingCoInsured
                        if vm.coInsuredAdded.count < nbOfMissingCoInsured {
                            let nbOfFields = nbOfMissingCoInsured - vm.coInsuredAdded.count
                            hSection {
                                ForEach((1...nbOfFields), id: \.self) { index in
                                    CoInsuredField(
                                        accessoryView: emptyAccessoryView,
                                        title: L10n.contractCoinsured,
                                        subTitle: L10n.contractNoInformation
                                    )
                                }
                            }
                            .sectionContainerStyle(.transparent)
                            //                            hSection {
                            //                                InfoCard(text: "TBD", type: .info)
                            //                            }
                            .sectionContainerStyle(.transparent)
                        } else {
                            hSection {
                                InfoCard(text: L10n.contractAddCoinsuredReviewInfo, type: .attention)
                            }
                        }
                    }
                }
            }
        }
        .hFormAttachToBottom {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.contractForId(contractId)
                }
            ) { contract in
                VStack(spacing: 8) {
                    if let contract = contract {
                        let nbOfMissingCoInsured = contract.nbOfMissingCoInsured
                        if vm.coInsuredAdded.count >= nbOfMissingCoInsured {
                            hButton.LargeButton(type: .primary) {
                                store.send(.performCoInsuredChanges(commitId: intentVm.id))
                                store.send(
                                    .coInsuredNavigationAction(action: .openCoInsuredProcessScreen(showSuccess: false))
                                )
                            } content: {
                                hText(L10n.generalSaveChangesButton)
                            }
                            .trackLoading(ContractStore.self, action: .postCoInsured)
                            .disabled(
                                ((contract.currentAgreement?.coInsured.count ?? 0) + vm.coInsuredAdded.count)
                                    < nbOfMissingCoInsured
                            )
                            .padding(.horizontal, 16)
                        }

                        hButton.LargeButton(type: .ghost) {
                            store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                        .disableOn(ContractStore.self, [.postCoInsured])
                    }
                }
            }
        }
    }

    @ViewBuilder
    func localAccessoryView(coInsured: CoInsuredModel) -> some View {
        hText(L10n.Claims.Edit.Screen.title)
            .onTapGesture {
                store.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            actionType: .edit,
                            coInsuredModel: coInsured,
                            title: L10n.contractAddConisuredInfo,
                            contractId: contractId
                        )
                    )
                )
            }
    }

    @ViewBuilder
    var emptyAccessoryView: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state
            }
        ) { contract in
            HStack {
                hText(L10n.generalAddInfoButton)
                Image(uiImage: hCoreUIAssets.plusSmall.image)
            }
            .onTapGesture {
                if !contract.fetchAllCoInsured.isEmpty {
                    store.send(
                        .coInsuredNavigationAction(
                            action: .openCoInsuredSelectScreen(contractId: contractId)
                        )
                    )
                } else {
                    store.send(
                        .coInsuredNavigationAction(
                            action: .openCoInsuredInput(
                                actionType: .add,
                                coInsuredModel: CoInsuredModel(),
                                title: L10n.contractAddConisuredInfo,
                                contractId: contractId
                            )
                        )
                    )
                }
            }
        }
    }
}

struct InsuredPeopleScreenNew_Previews: PreviewProvider {
    static var previews: some View {
        InsuredPeopleScreen(contractId: "")
    }
}
