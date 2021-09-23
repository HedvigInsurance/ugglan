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
            return state.contracts.filter { contract in
                contract.currentAgreement.status == .terminated
            }
        case .none: return []
        }
    }
}

extension ContractTable: View {
    var body: some View {
        hSection {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    getContractsToShow(for: state, filter: filter)
                }
            ) { contracts in
                ForEach(contracts, id: \.id) { contract in
                    if contract == contracts.last {
                        ContractRow(contract: contract)
                    } else {
                        ContractRow(contract: contract)
                            .padding(.bottom, 15)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)

        if self.filter.displaysActiveContracts {
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
                        .onTap {
                            store.send(.openTerminatedContracts)
                        }
                    }
                }
            }
        }
    }
}
