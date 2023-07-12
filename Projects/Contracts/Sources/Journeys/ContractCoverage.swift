import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractCoverageView: View {
    @PresentableStore var store: ContractStore
    let id: String

    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract = contract {
                VStack {
                    InsurableLimitsSectionView(
                        limits: contract.insurableLimits
                    ) { limit in
                    }
                    Spacer()
                    PerilCollection(perils: contract.contractPerils) { peril in
                    }
                }
            }
        }
    }
}
