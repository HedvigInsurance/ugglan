import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellMoreInfoSection: View {
    @PresentableStore var store: ContractStore
    let info: CrossSellInfo

    var body: some View {
        hSection(header: hText("Learn more")) {
            hRow {
                hText("Full Coverage")
            }
            .onTap {
                store.send(.crossSellingCoverageDetailNavigation(action: .detail))
            }
            hRow {
                hText("Common questions")
            }
            .onTap {
                store.send(.crossSellingFAQListNavigation(action: .list))
            }
        }
    }
}
