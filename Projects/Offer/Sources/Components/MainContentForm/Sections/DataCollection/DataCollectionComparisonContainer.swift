import Foundation
import SwiftUI
import hCoreUI
import hCore
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
                hSection(header: hText("Prisjämförelse")) {
                    hRow {
                        hText("Något gick fel och vi kunde tyvärr inte hämta någon information om din nuvarande hemförsäkring.")
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
