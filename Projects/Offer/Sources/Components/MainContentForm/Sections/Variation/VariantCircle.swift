import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct VariantCircle: View {
    var variant: QuoteVariant

    @hColorBuilder func backgroundColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.primary
        } else {
            hTintColorOld.clear
        }
    }

    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.currentVariant
            }
        ) { currentVariant in
            BulletView(isSelected: variant == currentVariant)
                .frame(
                    width: 22,
                    height: 22
                )
                .padding(2)
        }
    }
}
