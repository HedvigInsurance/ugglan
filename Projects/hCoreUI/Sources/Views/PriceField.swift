import SwiftUI
import hCore
import hGraphQL

public struct PriceField: View {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?
    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice
    let multiplier = HFontTextStyle.body1.multiplier

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

            if strikeThroughPrice, newPremium != currentPremium {
                if #available(iOS 16.0, *) {
                    hText(currentPremium?.formattedAmountPerMonth ?? "")
                        .strikethrough()
                        .foregroundColor(hTextColor.Opaque.secondary)
                } else {
                    hText(currentPremium?.formattedAmountPerMonth ?? "")
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }

            VStack(alignment: .trailing, spacing: multiplier != 1 ? .padding8 * multiplier : 0) {
                hText(newPremium?.formattedAmountPerMonth ?? currentPremium?.formattedAmountPerMonth ?? "")

                if let currentPremium, let newPremium, newPremium != currentPremium, !strikeThroughPrice {
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

#Preview {
    hSection {
        PriceField(
            newPremium: .init(amount: "99", currency: "SEK"),
            currentPremium: MonetaryAmount(amount: "49", currency: "SEK")
        )
        .hWithStrikeThroughPrice(setTo: true)
    }
    .sectionContainerStyle(.transparent)
}

private struct EnvironmentHWithStrikeThroughPrice: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hWithStrikeThroughPrice: Bool {
        get { self[EnvironmentHWithStrikeThroughPrice.self] }
        set { self[EnvironmentHWithStrikeThroughPrice.self] = newValue }
    }
}

extension View {
    public func hWithStrikeThroughPrice(setTo: Bool) -> some View {
        self.environment(\.hWithStrikeThroughPrice, setTo)
    }
}
