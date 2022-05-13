import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct VariantSelector: View {
    @PresentableStore var store: OfferStore

    var variant: QuoteVariant

    var price: String {
        "\(variant.bundle.bundleCost.monthlyNet.formattedAmountWithoutSymbol)\(variant.bundle.bundleCost.monthlyNet.currencySymbol)\(L10n.perMonth)"
    }

    var body: some View {
        hRow {
            HStack(alignment: .top, spacing: 12) {
                VariantCircle(variant: variant)
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        hText(variant.bundle.displayName, style: .title3)
                            .fixedSize(horizontal: false, vertical: true)
                        if let tag = variant.tag {
                            hText(tag, style: .footnote).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    hText(price).foregroundColor(hLabelColor.secondary)
                }
            }
        }
        .withEmptyAccessory
        .onTap {
            store.send(.setSelectedIds(ids: variant.bundle.quotes.map { $0.id }))
        }
        .overlay(
            VariantOverlay(variant: variant)
        )
        .background(hBackgroundColor.tertiary)
        .cornerRadius(.defaultCornerRadius)
        .clipped()
        .hShadow()
    }
}
