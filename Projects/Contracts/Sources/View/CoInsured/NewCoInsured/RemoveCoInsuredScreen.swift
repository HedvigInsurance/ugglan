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
                        ContractOwnerField(coInsured: contract.coInsured)
                        let missingCoInsured = contract.coInsured.filter {
                            $0.hasMissingData
                        }
                        let exisistingCoInsured = contract.coInsured.filter {
                            !$0.hasMissingData
                        }
                        hSection {
                            ForEach(exisistingCoInsured, id: \.self) { coInsured in
                                CoInsuredField(
                                    coInsured: coInsured,
                                    accessoryView: accessoryView(coInsured)
                                )
                            }
                            ForEach(missingCoInsured, id: \.self) { missingCoInsured in
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

    @ViewBuilder
    func accessoryView(_ coInsuredModel: CoInsuredModel) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.secondary)
            .onTapGesture {
                store.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            isDeletion: true,
                            coInsuredModel: coInsuredModel,
                            title: L10n.contractRemoveCoinsuredConfirmation,
                            contractId: contractId
                        )
                    )
                )
            }
    }
}
