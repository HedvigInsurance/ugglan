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
    
    func getContractsToShow(for state: ContractState) -> [Contract] {
        return state.activeContracts.compactMap { $0 }
        /* TODO ADD PENDING CONTRACTS*/
    }
}

extension ContractTable: View {
    var body: some View {
        LoadingViewWithContent(ContractStore.self, [.fetchContractBundles], [.fetchContractBundles], showLoading: false)
        {
            hSection {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        getContractsToShow(for: state)
                        
                    }
                ) { contracts in
                    ForEach(contracts, id: \.id) { contract in
                        ContractRow(id: contract.id)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                            .transition(.slide)
                    }
                }
            }
            .presentableStoreLensAnimation(.spring())
            .sectionContainerStyle(.transparent)
        }
        CrossSellingStack(withHeader: true)
            .padding(.top, 24)
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.terminatedContracts
            }
        ) { terminatedContracts in
            if !terminatedContracts.isEmpty {
                hSection {
                    hButton.LargeButton(type: .secondary) {
                        store.send(.openTerminatedContracts)
                    } content: {
                        hRow {
                            hText(L10n.InsurancesTab.cancelledInsurancesLabel("\(terminatedContracts.count)"))
                                .foregroundColor(hTextColorNew.primary)
                        }
                        .withChevronAccessory
                        .foregroundColor(hTextColorNew.secondary)
                    }
                }
                .transition(.slide)
            }
        }
        .presentableStoreLensAnimation(.spring())
        .sectionContainerStyle(.transparent)
        .padding(.bottom, 24)
    }
}
