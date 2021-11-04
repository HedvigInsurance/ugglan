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
                state.status
            }
        ) { status in
            switch status {
            case .failed, .login:
                hSection(header: hText(L10n.offerPriceComparisionHeader)) {
                    hRow {
                        hText(
                            L10n.offerComparisionError
                        )
                    }
                }
            case .completed:
                DataCollectionComparisonList()
            case .none:
                EmptyView()
            case .started, .collecting:
                ActivityIndicator(isAnimating: true)
            }
        }
    }
}
