import SwiftUI
import hCore
import hGraphQL

struct PriceField: View {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?

    var body: some View {

        HStack(alignment: .top) {
            hText(L10n.tierFlowTotal)
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                if let newPremium = newPremium {
                    hText(newPremium.formattedAmountPerMonth)
                } else {
                    hText(currentPremium?.formattedAmountPerMonth ?? "")
                }

                if newPremium != currentPremium {
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
