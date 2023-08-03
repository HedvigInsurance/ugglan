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
        LoadingViewWithContent(ContractStore.self, [.fetchContractBundles]) {
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
                            .padding(.top, 16)
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
            if self.filter.displaysActiveContracts {
                CrossSellingStack()
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        getContractsToShow(for: state, filter: .terminated(ifEmpty: .none))
                    }
                ) { terminatedContracts in
                    if !terminatedContracts.isEmpty {
                        hSection {
                            hButton.LargeButtonSecondary {
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
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.vertical, 16)
    }
}
