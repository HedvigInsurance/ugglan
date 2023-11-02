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
                            ContractOwnerField(coInsured: coInsured)
                            let missingCoInsured = coInsured.filter {
                                $0 == CoInsuredModel(fullName: nil, SSN: nil, needsMissingInfo: true)
                            }
                            let exisistingCoInsured = coInsured.filter {
                                $0 != CoInsuredModel(fullName: nil, SSN: nil, needsMissingInfo: true)
                            }
                            hSection {
                                ForEach(exisistingCoInsured, id: \.self) { coInsured in
                                    CoInsuredField(
                                        coInsured: coInsured,
                                        accessoryView: accessoryView(
                                            fullName: coInsured.fullName,
                                            SSN: coInsured.SSN
                                        )
                                    )
                                }
                                ForEach(missingCoInsured, id: \.self) { missingCoInsured in
                                    CoInsuredField(
                                        accessoryView: accessoryView(
                                            fullName: nil,
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
    }

    @ViewBuilder
    func accessoryView(fullName: String?, SSN: String?) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.secondary)
            .onTapGesture {
                store.send(
                    .coInsuredNavigationAction(
                        action: .openCoInsuredInput(
                            actionType: .delete,
                            fullName: fullName,
                            personalNumber: SSN,
                            title: L10n.contractRemoveCoinsuredConfirmation,
                            contractId: contractId
                        )
                    )
                )
            }
    }
}
