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
    let perils: [Perils]
    let insurableLimits: [InsurableLimits]

    var body: some View {
        VStack {
            hSection {
                PerilCollection(perils: perils) { peril in
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
                limits: insurableLimits
            ) { limit in
                store.send(.contractDetailNavigationAction(action: .insurableLimit(insurableLimit: limit)))
            }
        }
    }
}
