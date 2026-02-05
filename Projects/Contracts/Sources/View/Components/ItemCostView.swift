import SwiftUI
import hCore
import hCoreUI

struct ItemCostView: View {
    let itemCost: ItemCost
    @State private var detentPriceBreakdownModel: PriceFieldModel.PriceFieldInfoModel?
    var body: some View {
        hSection {
            hRow {
                content
            }
        }
        .showPriceBreakdown(for: $detentPriceBreakdownModel)
    }

    private var content: some View {
        HStack(spacing: .padding2) {
            hText(L10n.detailsTableInsurancePremium)
            Spacer()
            hText(itemCost.premium.net.priceFormat(.perMonth))
                .foregroundColor(hTextColor.Opaque.secondary)
            hCoreUIAssets.infoFilled.view
                .foregroundColor(hFillColor.Opaque.secondary)
                .accessibilityLabel(
                    L10n.voiceoverMoreInfo
                )
        }
        .onTapGesture {
            infoButtonTapAction()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityElement(children: .combine)
        .accessibilityAction {
            infoButtonTapAction()
        }
    }

    private func infoButtonTapAction() {
        detentPriceBreakdownModel = .init(
            initialValue: itemCost.premium.gross,
            newValue: itemCost.premium.net,
            infoButtonDisplayItems: itemCost.discounts.map { item in
                .init(title: item.displayName, value: item.displayValue)
            }
        )
    }
}
