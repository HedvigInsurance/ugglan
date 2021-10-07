import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ContinueButton: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell

    var body: some View {
        VStack {
            hGrayscaleColor.one.frame(height: .hairlineWidth)
            hButton.LargeButtonFilled {
                if let embarkStoryName = crossSell.embarkStoryName {
                    store.send(.openCrossSellingEmbark(name: embarkStoryName))
                }
            } content: {
                hText("Calculate your price")
            }
            .padding(16)
        }
        .background(hBackgroundColor.secondary.edgesIgnoringSafeArea(.bottom))
    }
}
