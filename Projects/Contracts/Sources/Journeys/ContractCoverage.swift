import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

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
                VStack(spacing: 4) {
                    InsurableLimitsSectionView(
                        limits: contract.currentAgreement?.productVariant.insurableLimits ?? []
                    ) { limit in
                        contractsNavigationVm.insurableLimit = limit
                    }
                    PerilCollection(
                        perils: contract.currentAgreement?.productVariant.perils ?? []
                    )
                    .hFieldSize(.small)
                }
            }
        }
    }
}
