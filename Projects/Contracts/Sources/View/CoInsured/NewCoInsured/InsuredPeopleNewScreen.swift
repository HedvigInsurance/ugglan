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
                        
                        hSection(vm.coInsured, id: \.self) { localCoInsured in
                            CoInsuredField(
                                coInsured: localCoInsured,
                                accessoryView: localAccessoryView(coInsured: localCoInsured)
                            )
                        }
                        .sectionContainerStyle(.transparent)
                        
                        if vm.coInsured.count < contractNbOfCoinsured {
                            emptyCoInsuredField(localCoInsured: vm.coInsured)
                        } else {
                            hSection {
                                InfoCard(text: L10n.contractAddCoinsuredReviewInfo, type: .attention)
                            }
                            .padding(.top, 16)
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
                        if (vm.coInsured.count >= contractNbOfCoinsured) {
                            hButton.LargeButton(type: .primary) {
                                store.send(.applyLocalCoInsured(coInsured: vm.coInsured, contractId: contractId))
                                store.send(.coInsuredNavigationAction(action: .openCoInsuredProcessScreen(showSuccess: false)))
                            } content: {
                                hText(L10n.generalSaveChangesButton)
                            }
                            .disabled((contract.coInsured.count + vm.coInsured.count) < contractNbOfCoinsured)
                            .padding(.horizontal, 16)
                        }
                        
                        hButton.LargeButton(type: .ghost) {
                            store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                        .padding(.horizontal, 16)
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
                            name: coInsured.name,
                            personalNumber: coInsured.SSN,
                            title: L10n.contractAddConisuredInfo,
                            contractId: contractId
                        )
                    )
                )
            }
    }
    
    @ViewBuilder
    func emptyAccessoryView(coInsured: CoInsuredModel) -> some View {
        HStack {
            hText(L10n.generalAddInfoButton)
            Image(uiImage: hCoreUIAssets.plusSmall.image)
        }
        .onTapGesture {
            store.send(
                .coInsuredNavigationAction(action: .openCoInsuredInput(
                    isDeletion: false,
                    name: nil,
                    personalNumber: nil,
                    title: L10n.contractAddConisuredInfo,
                    contractId: contractId
                )
                ))
        }
    }
    
    func emptyCoInsuredField(localCoInsured: [CoInsuredModel]) -> some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state
            }
        ) { contract in
            hSection {
                let nbOfFields = contractNbOfCoinsured - localCoInsured.count
                ForEach((1...nbOfFields), id: \.self) { index in
                    VStack {
                        HStack {
                            hText(L10n.contractCoinsured)
                            Spacer()
                            HStack {
                                hText(L10n.generalAddInfoButton)
                                Image(uiImage: hCoreUIAssets.plusSmall.image)
                            }
                            .onTapGesture {
                                if !contract.fetchAllCoInsured.isEmpty {
                                    store.send(.coInsuredNavigationAction(action: .openCoInsuredSelectScreen(contractId: contractId)))
                                } else {
                                    store.send(
                                        .coInsuredNavigationAction(action: .openCoInsuredInput(
                                            isDeletion: true,
                                            name: nil,
                                            personalNumber: nil,
                                            title: L10n.contractAddConisuredInfo,
                                            contractId: contractId
                                        )
                                        ))
                                }
                            }
                        }
                        hText(L10n.contractNoInformation)
                            .foregroundColor(hTextColor.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 16)
                    hRowDivider()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

struct InsuredPeopleScreenNew_Previews: PreviewProvider {
    static var previews: some View {
        InsuredPeopleScreen(contractId: "")
    }
}
