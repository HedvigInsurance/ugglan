import Foundation
import SwiftUI
import hCoreUI
import hCore
import hGraphQL

struct VariantSelector: View {
    @PresentableStore var store: OfferStore
    
    var variant: QuoteVariant
    
    var price: String {
        "\(variant.bundle.bundleCost.monthlyNet.formattedAmountWithoutSymbol)\(variant.bundle.bundleCost.monthlyNet.currencySymbol)\(L10n.perMonth)"
    }
    
    var body: some View {
        hRow {
            VStack(alignment: .leading, spacing: 25) {
                HStack(spacing: 9) {
                    VariantCircle(variant: variant)
                    if let tag = variant.tag {
                        hText(tag, style: .footnote).foregroundColor(.secondary)
                    }
                }
                HStack(alignment: .bottom) {
                    VStack {
                        hText(variant.bundle.displayName, style: .title3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    hText(price).foregroundColor(hLabelColor.secondary)
                }
            }
        }
        .withEmptyAccessory
        .onTap {
            store.send(.setSelectedIds(ids: variant.bundle.quotes.map { $0.id }))
            
            UIApplication.shared.windows.forEach { window in
                UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
        .overlay(
            VariantOverlay(variant: variant)
        )
    }
}
