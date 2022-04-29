import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct VariantCircle: View {
    var variant: QuoteVariant

    @hColorBuilder func backgroundColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hLabelColor.primary
        } else {
            hTintColor.clear
        }
    }

    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.currentVariant
            }
        ) { currentVariant in
            VStack {
                if currentVariant == variant {
                    hCoreUIAssets.checkmark.view
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
            }
            .padding(2)
            .frame(
                width: 22,
                height: 22
            )
            .background(Circle().strokeBorder(hSeparatorColor.separator, lineWidth: 1))
            .background(Circle().fill(backgroundColor(isSelected: currentVariant == variant)))
        }
    }
}
