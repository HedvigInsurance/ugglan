import AppStateContainer
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ContractCoverageView: View {
    @AppObservedObject var store: ContractStore
    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel
    let id: String

    var body: some View {
        if let contract = store.contractForId(id) {
            CoverageView(
                limits: contract.currentAgreement?.productVariant.insurableLimits ?? [],
                didTapInsurableLimit: { limit in
                    contractsNavigationVm.insurableLimit = limit
                },
                perils: contract.allPerils
            )
        }
    }
}

extension Contract {
    var allPerils: [(title: String?, perils: [Perils])] {
        var allPerils: [(title: String?, perils: [Perils])] = []
        allPerils.append((nil, currentAgreement?.productVariant.perils ?? []))
        let addonPerils: [(title: String?, perils: [Perils])] =
            currentAgreement?.addonVariant.compactMap { ($0.displayName, $0.perils) } ?? []
        allPerils.append(contentsOf: addonPerils)
        return allPerils
    }
}
