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
                        let missingCoInsured = 2 - contract.coInsured.count /* TODO: CHANGE WHEN WE HAVE REAL DATA */

                        hSection {
                            ForEach(contract.coInsured, id: \.self) { coInsured in
                                CoInsuredField(
                                    coInsured: coInsured,
                                    accessoryView: accessoryView(
                                        firstName: coInsured.firstName,
                                        lastName: coInsured.lastName,
                                        SSN: coInsured.SSN
                                    )
                                )
                            }
                            ForEach(0..<missingCoInsured, id: \.self) { missingCoInsured in
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
