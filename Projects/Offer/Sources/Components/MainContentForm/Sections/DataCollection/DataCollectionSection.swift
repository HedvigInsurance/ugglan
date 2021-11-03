import Foundation
import SwiftUI
import hCoreUI
import hCore
import hGraphQL

struct DataCollectionSection: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.dataCollectionEnabled
            }
        ) { dataCollectionEnabled in
            if dataCollectionEnabled {
                DataCollectionComparisonContainer()
            }
        }.presentableStoreLensAnimation(.spring())
    }
}
