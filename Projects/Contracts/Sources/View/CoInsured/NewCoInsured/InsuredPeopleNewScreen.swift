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
                        let listToDisplay = listToDisplay(contract: contract)
                        let hasContentBelow = !listToDisplay.isEmpty

                        hSection {
                            hRow {
                                ContractOwnerField(contractId: contractId, hasContentBelow: hasContentBelow)
                            }
                            .verticalPadding(0)
                            .padding(.top, 16)
                        }
                        .withoutHorizontalPadding
                        .sectionContainerStyle(.transparent)

                        hSection {
                            ForEach(Array(listToDisplay.enumerated()), id: \.0) {
                                index,
                                coInsured in
                                hRow {
                                    CoInsuredField(
                                        coInsured: coInsured.coInsured,
                                        accessoryView: getAccView(coInsured: coInsured),
                                        title: coInsured.coInsured.hasMissingData ? L10n.contractCoinsured : nil,
                                        subTitle: coInsured.coInsured.hasMissingData ? L10n.contractNoInformation : nil
                                    )
                                }
                                if index != listToDisplay.count - 1 {
                                    hRowDivider()
                                }
                            }
                        }
                        .withoutHorizontalPadding
                        .sectionContainerStyle(.transparent)

                        if vm.coInsuredAdded.count >= contract.nbOfMissingCoInsured {
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
    func getAccView(coInsured: CoInsuredListType) -> some View {
        if coInsured.coInsured.hasMissingData {
            emptyAccessoryView
        } else {
            localAccessoryView(coInsured: coInsured.coInsured)
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
                let hasExistingCoInsured = contract.fetchAllCoInsured.filter { !vm.coInsuredAdded.contains($0) }
                if !hasExistingCoInsured.isEmpty {
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

    func listToDisplay(contract: Contract) -> [CoInsuredListType] {
        var finalList: [CoInsuredListType] = []
        var addedCoInsured: [CoInsuredListType] = []

        vm.coInsuredAdded.forEach {
            addedCoInsured.append(CoInsuredListType(coInsured: $0, type: .added, locallyAdded: true))
        }

        let nbOfMissingCoInsured = contract.nbOfMissingCoInsured
        if vm.coInsuredAdded.count < nbOfMissingCoInsured {
            let nbOfFields = nbOfMissingCoInsured - vm.coInsuredAdded.count
            for _ in 1...nbOfFields {
                finalList.append(CoInsuredListType(coInsured: CoInsuredModel(), type: nil, locallyAdded: false))
            }
        }
        return addedCoInsured + finalList
    }
}

struct InsuredPeopleScreenNew_Previews: PreviewProvider {
    static var previews: some View {
        InsuredPeopleScreen(contractId: "")
    }
}
