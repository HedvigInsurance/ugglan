import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DataCollectionComparisonContainer: View {
    var body: some View {
        PresentableStoreLens(
            DataCollectionStore.self,
            getter: { state in
                state.allStatuses
            }
        ) { statuses in
            if statuses.contains(.completed) {
                DataCollectionComparisonList()
            } else if statuses.contains(.failed) || statuses.contains(.login) {
                hSection(header: hText(L10n.offerPriceComparisionHeader)) {
                    hRow {
                        hText(
                            L10n.offerComparisionError
                        )
                    }
                }
            } else if statuses.contains(.started) || statuses.contains(.collecting) {
                ActivityIndicator(style: .medium)
            }
        }
    }
}
