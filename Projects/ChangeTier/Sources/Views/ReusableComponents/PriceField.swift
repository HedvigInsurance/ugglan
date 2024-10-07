import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct PriceField: View {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?

    var body: some View {

        HStack(alignment: .top) {
            hText(L10n.tierFlowTotal)
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                hText(newPremium?.formattedAmountPerMonth ?? currentPremium?.formattedAmountPerMonth ?? "")

                if let newPremium, let currentPremium, newPremium != currentPremium {
                    hText(
                        L10n.tierFlowPreviousPrice(currentPremium.formattedAmountPerMonth),
                        style: .label
                    )
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
    }
}
