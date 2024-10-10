import SwiftUI
import hCore
import hGraphQL

public struct PriceField: View {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?

    public init(
        newPremium: MonetaryAmount?,
        currentPremium: MonetaryAmount?
    ) {
        self.newPremium = newPremium
        self.currentPremium = currentPremium
    }

    public var body: some View {
        HStack(alignment: .top) {
            hText(L10n.tierFlowTotal)
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                hText(newPremium?.formattedAmountPerMonth ?? currentPremium?.formattedAmountPerMonth ?? "")

                if let newPremium, newPremium != currentPremium {
                    hText(
                        L10n.tierFlowPreviousPrice(currentPremium?.formattedAmountPerMonth ?? ""),
                        style: .label
                    )
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
    }
}
