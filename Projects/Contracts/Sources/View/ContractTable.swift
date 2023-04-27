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
    let filter: ContractFilter
    @PresentableStore var store: ContractStore
    
    func getContractsToShow(for state: ContractState, filter: ContractFilter) -> [Contract] {
        switch filter {
        case .active:
            return state
                .contractBundles
                .flatMap { $0.contracts }
        case .terminated:
            return state.contracts
                .filter { contract in
                    contract.currentAgreement?.status == .terminated
                }
        case .none: return []
        }
    }
}

extension ContractTable: View {
    var body: some View {
        LoadingViewWithContent(.fetchContractBundles, withRetry: true) {
            hSection {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        getContractsToShow(for: state, filter: filter.nonemptyFilter(state: state))
                    }
                ) { contracts in
                    ForEach(contracts, id: \.id) { contract in
                        ContractRow(id: contract.id)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 15)
                            .transition(.slide)
                    }
                }
            }
            .presentableStoreLensAnimation(.spring())
            .sectionContainerStyle(.transparent)
            
        }
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                return self.filter.nonemptyFilter(state: state).displaysActiveContracts
            }
        ) { displaysActiveContracts in
            if displaysActiveContracts {
                CrossSellingStack()
                
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        getContractsToShow(for: state, filter: .terminated(ifEmpty: .none))
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
        }
    }
}
