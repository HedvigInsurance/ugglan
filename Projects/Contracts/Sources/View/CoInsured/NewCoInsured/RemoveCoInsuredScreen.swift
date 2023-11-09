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
                            let missingCoInsured = coInsured.filter {
                                $0.hasMissingData
                            }
                            let exisistingCoInsured = coInsured.filter {
                                !$0.hasMissingData
                            }
                            hSection {
                                ForEach(exisistingCoInsured, id: \.self) { coInsured in
                                    CoInsuredField(
                                        coInsured: coInsured,
                                        accessoryView: accessoryView(coInsured)
                                    )
                                }
                                let nbOfMissingoInsured = missingCoInsured.count - vm.coInsuredDeleted.count
                                ForEach(0..<nbOfMissingoInsured, id: \.self) { missingCoInsured in
                                    CoInsuredField(
                                        accessoryView: accessoryView(.init()),
                                        title: L10n.contractCoinsured,
                                        subTitle: L10n.contractNoInformation
                                    )
                                }
                            }
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
