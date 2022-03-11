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
            hButton.LargeButtonFilled {
                if let embarkStoryName = crossSell.embarkStoryName {
                    store.send(.crossSellingDetailEmbark(name: embarkStoryName))
                }
            } content: {
                hText(L10n.CrossSellingCardSeAccident.cta)
            }
        }
    }
}
