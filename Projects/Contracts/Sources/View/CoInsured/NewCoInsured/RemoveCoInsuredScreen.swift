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
                            $0 == CoInsuredModel(firstName: nil, lastName: nil, SSN: nil)
                        }
                        let exisistingCoInsured = contract.coInsured.filter {
                            $0 != CoInsuredModel(firstName: nil, lastName: nil, SSN: nil)
                        }
                        hSection {
                            ForEach(exisistingCoInsured, id: \.self) { coInsured in
                                CoInsuredField(
                                    coInsured: coInsured,
                                    accessoryView: accessoryView(
                                        firstName: coInsured.firstName,
                                        lastName: coInsured.lastName,
                                        SSN: coInsured.SSN
                                    )
                                )
                            }
                            ForEach(missingCoInsured, id: \.self) { missingCoInsured in
                                CoInsuredField(
                                    accessoryView: accessoryView(
                                        firstName: nil,
                                        lastName: nil,
                                        SSN: nil
                                    ),
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
    func accessoryView(firstName: String?, lastName: String?, SSN: String?) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.secondary)
            .onTapGesture {
                store.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            isDeletion: true,
                            firstName: firstName,
                            lastName: lastName,
                            personalNumber: SSN,
                            title: L10n.contractRemoveCoinsuredConfirmation,
                            contractId: contractId
                        )
                    )
                )
            }
    }
}
