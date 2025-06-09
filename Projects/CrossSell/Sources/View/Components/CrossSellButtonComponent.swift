import SwiftUI
import hCore
import hCoreUI

struct CrossSellButtonComponent: View {
    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.crossSellButton),
                    {
                        /** TODO: IMPLEMENT */
                    }
                )

                hText(L10n.crossSellLabel, style: .finePrint)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
