import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct ContractCoverageView: View {
    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel
    let id: String

    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract = contract {
                CoverageView(
                    limits: contract.currentAgreement?.agreementVariant.productVariant.insurableLimits ?? [],
                    didTapInsurableLimit: { limit in
                        contractsNavigationVm.insurableLimit = limit
                    },
                    perils: contract.allPerils
                )
            }
        }
    }
}

extension Contract {
    var allPerils: [(title: String?, perils: [Perils])] {
        var allPerils: [(title: String?, perils: [Perils])] = []
        allPerils.append((nil, currentAgreement?.agreementVariant.productVariant.perils ?? []))
        let addonPerils: [(title: String?, perils: [Perils])] =
            currentAgreement?.agreementVariant.addonVariant.compactMap { ($0.displayName, $0.perils) } ?? []
        allPerils.append(contentsOf: addonPerils)
        return allPerils
    }
}
