import Foundation
import SwiftUI
import hCoreUI
import hCore

struct VariationSection: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.offerData?.possibleVariations ?? []
            }
        ) { possibleVariations in
            if possibleVariations.count != 1 {
                VStack {
                    hText("Ditt försäkringspaket", style: .headline)
                    
                    ForEach(possibleVariations, id: \.id) { possibleVariation in
                        hRow {
                            hText(possibleVariation.tag ?? "")
                        }
                    }
                }
            }
        }
    }
}
