import Apollo
import Flow
import Form
import Foundation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractTable {
    @PresentableStore var store: ContractStore

    @State
    var contracts = [Contract]()

    private func updateContracts(for state: ContractState) {
        let contracts = store.state.contracts + store.state.contractBundles.flatMap { $0.contracts }
        
        self.contracts = contracts.isEmpty ? state.terminatedContracts : Array(Set(contracts))
    }
}

extension ContractTable: View {
    var body: some View {
        ContractBundleLoadingIndicator()

        hSection {
            ForEach(contracts, id: \.id) { contract in
                ContractRow(id: contract.id)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 15)
                    .transition(.slide)
            }
        }
        .presentableStoreLensAnimation(.spring())
        .sectionContainerStyle(.transparent)

        if contracts.contains(where: { $0.currentAgreement?.status == .active }) {
            CrossSellingStack()
        }

        hSection {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    return state.terminatedContracts
                }
            ) { terminatedContracts in
                if !terminatedContracts.isEmpty {
                    hSection(header: hText(L10n.InsurancesTab.moreTitle)) {
                        hRow {
                            hText(L10n.InsurancesTab.terminatedInsurancesLabel)
                        }
                        .withCustomAccessory({
                            Spacer()
                            hText(String(terminatedContracts.count), style: .body)
                                .foregroundColor(hLabelColor.secondary)
                                .padding(.trailing, 8)
                            StandaloneChevronAccessory()
                        })
                        .onTap {
                            store.send(.openTerminatedContracts)
                        }
                    }
                    .transition(.slide)
                }
            }
            .presentableStoreLensAnimation(.spring())
        }
        .onReceive(store.stateSignal.atOnce().plain().publisher) { state in
            updateContracts(for: state)
        }
        .onAppear {
            updateContracts(for: store.state)
        }
    }
}
