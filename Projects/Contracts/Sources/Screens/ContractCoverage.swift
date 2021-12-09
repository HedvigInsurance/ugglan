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
        PresentableStoreLens(ContractStore.self, getter: { state in
            state.contractForId(id)
        }) { contract in
            if let contract = contract {
                VStack {
                    hSection {
                        PerilCollection(perils: contract.contractPerils) { peril in
                            store.send(.contractDetailNavigationAction(action: .peril(peril: peril)))
                        }
                    }
                    .sectionContainerStyle(.transparent)
                    Spacer()
                    SwiftUI.Divider()
                    Spacer()
                    InsurableLimitsSectionView(
                        header: hText(
                            L10n.contractCoverageMoreInfo,
                            style: .headline
                        )
                        .foregroundColor(hLabelColor.secondary),
                        limits: contract.insurableLimits
                    ) { limit in
                        store.send(.contractDetailNavigationAction(action: .insurableLimit(insurableLimit: limit)))
                    }
                }
            }
        }
    }
}
