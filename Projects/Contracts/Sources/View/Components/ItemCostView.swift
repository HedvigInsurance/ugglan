import SwiftUI
import hCore
import hCoreUI

struct ItemCostView: View {
    let itemCost: ItemCost
    @State private var detentPriceBreakdownModel: PriceFieldModel?
    var body: some View {
        hSection {
            hRow {
                HStack(spacing: .padding2) {
                    hText(L10n.detailsTableInsurancePremium)
                    Spacer()
                    hText(itemCost.net.priceFormat(.perMonth))
                        .foregroundColor(hTextColor.Opaque.secondary)
                    hCoreUIAssets.infoFilled.view
                        .foregroundColor(hFillColor.Opaque.secondary)
                        .onTapGesture {
                            detentPriceBreakdownModel = .init(
                                initialValue: itemCost.gross,
                                newValue: itemCost.net,
                                title: L10n.detailsTableInsurancePremium,
                                infoButtonDisplayItems: itemCost.discounts.map { item in
                                    .init(title: item.displayName, value: item.displayValue)
                                }
                            )
                        }
                }
            }
        }
        .showPriceBreakdown(for: $detentPriceBreakdownModel)
    }
}
