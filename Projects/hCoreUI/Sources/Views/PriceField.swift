import SwiftUI
import hCore
import hGraphQL

public struct PriceField: View {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?
    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice

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
                .foregroundColor(getTotalColor())
            Spacer()

            if strikeThroughPrice != .none, newPremium != currentPremium {
                if #available(iOS 16.0, *) {
                    hText(currentPremium?.formattedAmountPerMonth ?? "")
                        .strikethrough()
                        .foregroundColor(hTextColor.Opaque.secondary)
                } else {
                    hText(currentPremium?.formattedAmountPerMonth ?? "")
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }

            VStack(alignment: .trailing, spacing: 0) {
                if strikeThroughPrice == .crossNewPrice {
                    if #available(iOS 16.0, *) {
                        hText(newPremium?.formattedAmountPerMonth ?? "")
                            .strikethrough()
                            .foregroundColor(hTextColor.Opaque.secondary)
                    } else {
                        hText(newPremium?.formattedAmountPerMonth ?? "")
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                } else {
                    hText(newPremium?.formattedAmountPerMonth ?? currentPremium?.formattedAmountPerMonth ?? "")
                }
                if let currentPremium, let newPremium, newPremium != currentPremium,
                    strikeThroughPrice != .crossOldPrice
                {
                    hText(
                        L10n.tierFlowPreviousPrice(currentPremium.formattedAmountPerMonth),
                        style: .label
                    )
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
    }

    @hColorBuilder
    private func getTotalColor() -> some hColor {
        switch strikeThroughPrice {
        case .crossNewPrice:
            hTextColor.Translucent.secondary
        case .crossOldPrice, .none:
            hTextColor.Opaque.primary
        }
    }
}

#Preview {
    hSection {
        PriceField(
            newPremium: .init(amount: "99", currency: "SEK"),
            currentPremium: MonetaryAmount(amount: "49", currency: "SEK")
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)

        PriceField(
            newPremium: .init(amount: "99", currency: "SEK"),
            currentPremium: nil
        )
        .hWithStrikeThroughPrice(setTo: .crossNewPrice)
    }
    .sectionContainerStyle(.transparent)
}

private struct EnvironmentHWithStrikeThroughPrice: EnvironmentKey {
    static let defaultValue: StrikeThroughPriceType = .none
}

public enum StrikeThroughPriceType: Sendable {
    case none
    case crossOldPrice
    case crossNewPrice
}

extension EnvironmentValues {
    public var hWithStrikeThroughPrice: StrikeThroughPriceType {
        get { self[EnvironmentHWithStrikeThroughPrice.self] }
        set { self[EnvironmentHWithStrikeThroughPrice.self] = newValue }
    }
}

extension View {
    public func hWithStrikeThroughPrice(setTo: StrikeThroughPriceType) -> some View {
        self.environment(\.hWithStrikeThroughPrice, setTo)
    }
}
