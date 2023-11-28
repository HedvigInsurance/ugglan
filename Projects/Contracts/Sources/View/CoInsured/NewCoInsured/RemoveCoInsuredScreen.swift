import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct RemoveCoInsuredScreen: View {
    @PresentableStore var store: ContractStore
    let contractId: String
    @ObservedObject var vm: InsuredPeopleNewScreenModel

    public init(
        contractId: String
    ) {
        self.contractId = contractId
        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        vm.initializeCoInsured(with: contractId)
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
                            let missingCoInsured = coInsured.filter {
                                return $0.hasMissingData
                            }

                            let missingInUpcoming =
                                contract.upcomingChangedAgreement?.coInsured.filter({ $0.hasMissingData }) ?? []

                            let exisistingCoInsured = coInsured.filter {
                                return !$0.hasMissingData
                            }

                            var nbOfMissingoInsured: Int {
                                if missingInUpcoming.count > 0 {
                                    return missingInUpcoming.count - vm.coInsuredDeleted.count
                                } else {
                                    return missingCoInsured.count - vm.coInsuredDeleted.count
                                }
                            }

                            let hasContentBelow = !exisistingCoInsured.isEmpty || nbOfMissingoInsured > 0

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
                                ForEach(exisistingCoInsured, id: \.self) { coInsured in
                                    hRow {
                                        CoInsuredField(
                                            coInsured: coInsured,
                                            accessoryView: accessoryView(coInsured)
                                        )
                                    }
                                }

                                ForEach(0..<nbOfMissingoInsured, id: \.self) { missingCoInsured in
                                    hRow {
                                        CoInsuredField(
                                            accessoryView: accessoryView(.init()),
                                            title: L10n.contractCoinsured,
                                            subTitle: L10n.contractNoInformation
                                        )
                                    }
                                    if missingCoInsured < nbOfMissingoInsured - 1 {
                                        hRowDivider()
                                    }
                                }
                            }
                            .withoutHorizontalPadding
                            .sectionContainerStyle(.transparent)
                        }
                    }
                }
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if vm.coInsuredAdded.count > 0 || vm.coInsuredDeleted.count > 0 {
                    ConfirmChangesView()
                }
                CancelButton()
                    .padding(.horizontal, 16)
            }
        }
        .hFormIgnoreKeyboard()
    }

    @ViewBuilder
    func accessoryView(_ coInsuredModel: CoInsuredModel) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.secondary)
            .onTapGesture {
                store.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            actionType: .delete,
                            coInsuredModel: coInsuredModel,
                            title: L10n.contractRemoveCoinsuredConfirmation,
                            contractId: contractId
                        )
                    )
                )
            }
    }
}
