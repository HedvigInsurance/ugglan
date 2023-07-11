import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ContinueButton: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell

    var body: some View {
        hFormBottomAttachedBackground {
            hButton.LargeButtonPrimary {
                if let embarkStoryName = crossSell.embarkStoryName {
                    store.send(.crossSellingDetailEmbark(name: embarkStoryName))
                } else if let urlString = crossSell.webActionURL, let url = URL(string: urlString) {
                    store.send(.crossSellWebAction(url: url))
                }
            } content: {
                hText(L10n.CrossSellingCardSeAccident.cta)
            }
        }
    }
}
