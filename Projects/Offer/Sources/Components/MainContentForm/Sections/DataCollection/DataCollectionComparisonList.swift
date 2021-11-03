import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DataCollectionComparisonList: View {
    @PresentableStore var store: DataCollectionStore
    
    var body: some View {
        hSection(header: hText("Prisjämförelse")) {
            hRow {
                hCoreUIAssets.wordmark.view.resizable().aspectRatio(contentMode: .fit).frame(width: 60)
            }
            .withCustomAccessory {
                Spacer()
                PresentableStoreLens(
                    OfferStore.self,
                    getter: { state in
                        state.currentVariant?.bundle.bundleCost.monthlyNet
                    }
                ) { netPremium in
                    if let netPremium = netPremium {
                        hText("\(netPremium.formattedAmount)\(L10n.perMonth)").foregroundColor(hLabelColor.secondary)
                    } else {
                        ActivityIndicator(isAnimating: true)
                    }
                }
            }
            hRow {
                PresentableStoreLens(
                    DataCollectionStore.self,
                    getter: { state in
                        state.providerDisplayName ?? ""
                    }
                ) { providerDisplayName in
                    hText(providerDisplayName).foregroundColor(hLabelColor.secondary)
                }
            }
            .withCustomAccessory {
                Spacer()
                PresentableStoreLens(
                    DataCollectionStore.self,
                    getter: { state in
                        state.netPremium
                    }
                ) { netPremium in
                    if let netPremium = netPremium {
                        hText("\(netPremium.formattedAmount)\(L10n.perMonth)").foregroundColor(hLabelColor.secondary)
                    } else {
                        ActivityIndicator(isAnimating: true)
                    }
                }
            }
        }.onAppear {
            store.send(.fetchInfo)
        }
    }
}
