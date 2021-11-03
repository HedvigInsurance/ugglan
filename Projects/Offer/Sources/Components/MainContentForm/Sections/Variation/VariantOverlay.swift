import Foundation
import SwiftUI
import hCoreUI
import hCore
import hGraphQL

struct VariantOverlay: View {
    var variant: QuoteVariant
    
    @hColorBuilder func borderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hLabelColor.primary
        } else {
            hSeparatorColor.separator
        }
    }
    
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.currentVariant
            }
        ) { currentVariant in
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .stroke(borderColor(isSelected: variant == currentVariant), lineWidth: 2)
        }
    }
}
