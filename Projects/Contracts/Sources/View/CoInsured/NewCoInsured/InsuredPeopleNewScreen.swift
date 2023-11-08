import Presentation
import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleNewScreen: View {
    @PresentableStore var store: ContractStore
    let contractId: String
    @State var contractNbOfCoinsured = 2 /* TODO: CHANGE WHEN WE HAVE REAL DATA */
    @ObservedObject var vm: InsuredPeopleNewScreenModel

    public init(
        contractId: String
    ) {
        self.contractId = contractId
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
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
                        ContractOwnerField(coInsured: contract.coInsured)

                        hSection(vm.coInsuredAdded, id: \.self) { localCoInsured in
                            CoInsuredField(
                                coInsured: localCoInsured,
                                accessoryView: localAccessoryView(coInsured: localCoInsured)
                            )
                        }
                        .sectionContainerStyle(.transparent)

                        if vm.coInsuredAdded.count < contractNbOfCoinsured {
                            let nbOfFields = contractNbOfCoinsured - vm.coInsuredAdded.count
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
                            hSection {
                                InfoCard(text: "TBD", type: .info)
                            }
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
                        if vm.coInsuredAdded.count >= contractNbOfCoinsured {
                            LoadingButtonWithContent(ContractStore.self, .postCoInsured) {
                                /* TODO: SEND MUTATION */
                                store.send(
                                    .coInsuredNavigationAction(action: .openCoInsuredProcessScreen(showSuccess: false))
                                )
                            } content: {
                                hText(L10n.generalSaveChangesButton)
                            }
                            .disabled((contract.coInsured.count + vm.coInsuredAdded.count) < contractNbOfCoinsured)
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
                            isDeletion: false,
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
                                isDeletion: false,
                                coInsuredModel: .init(),
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
