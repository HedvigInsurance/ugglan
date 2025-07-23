import SwiftUI
import hCore

public struct PriceField: View {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?
    let title: String?
    let subTitle: String?
    let withoutPreviousPriceText: Bool
    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice
    @SwiftUI.Environment(\.hPriceFormatting) var formatting

    public init(
        newPremium: MonetaryAmount?,
        currentPremium: MonetaryAmount?,
        title: String? = nil,
        subTitle: String? = nil,
        withoutPreviousPriceText: Bool? = false
    ) {
        self.newPremium = newPremium
        self.currentPremium = currentPremium
        self.title = title
        self.subTitle = subTitle
        self.withoutPreviousPriceText = withoutPreviousPriceText ?? false
    }

    public var body: some View {
        VStack(spacing: .padding2) {
            HStack(alignment: .top) {
                hText(title ?? L10n.tierFlowTotal)
                    .foregroundColor(getTotalColor())
                Spacer()

                if strikeThroughPrice != .none, newPremium != currentPremium {
                    if #available(iOS 16.0, *) {
                        hText(currentPremium?.priceFormat(formatting) ?? "")
                            .strikethrough()
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .accessibilityValue(L10n.voiceoverCurrentPrice)
                    } else {
                        hText(currentPremium?.priceFormat(formatting) ?? "")
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }

                VStack(alignment: .trailing, spacing: 0) {
                    if strikeThroughPrice == .crossNewPrice {
                        if #available(iOS 16.0, *) {
                            hText(newPremium?.priceFormat(formatting) ?? "")
                                .strikethrough()
                                .foregroundColor(hTextColor.Opaque.secondary)
                                .accessibilityValue(
                                    L10n.voiceoverCurrentPrice
                                )

                        } else {
                            hText(newPremium?.priceFormat(formatting) ?? "")
                                .foregroundColor(hTextColor.Opaque.secondary)
                                .accessibilityValue(
                                    L10n.ReferralsActive.Your.New.Price.title
                                )
                        }
                    } else {
                        hText(newPremium?.priceFormat(formatting) ?? currentPremium?.priceFormat(formatting) ?? "")
                    }

                    if let currentPremium, let newPremium, newPremium != currentPremium,
                        strikeThroughPrice != .crossOldPrice && !withoutPreviousPriceText
                    {
                        hText(
                            L10n.tierFlowPreviousPrice(currentPremium.priceFormat(formatting)),
                            style: .label
                        )
                        .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
            }
            if let subTitle {
                hText(subTitle, style: .label)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .accessibilityElement(children: .combine)
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

        PriceField(
            newPremium: .init(amount: "99", currency: "SEK"),
            currentPremium: MonetaryAmount(amount: "49", currency: "SEK"),
            subTitle: "sub title"
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
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

private struct EnvironmentHPriceFormatting: EnvironmentKey {
    static let defaultValue: PriceFormatting = .perMonth
}

public enum PriceFormatting: Sendable {
    case perMonth
    case month
}

extension EnvironmentValues {
    public var hPriceFormatting: PriceFormatting {
        get { self[EnvironmentHPriceFormatting.self] }
        set { self[EnvironmentHPriceFormatting.self] = newValue }
    }
}

extension View {
    public func hPriceFormatting(setTo: PriceFormatting) -> some View {
        self.environment(\.hPriceFormatting, setTo)
    }
}

extension MonetaryAmount {
    func priceFormat(_ format: PriceFormatting) -> String {
        switch format {
        case .perMonth:
            return self.formattedAmountPerMonth
        case .month:
            return self.formattedAmount
        }
    }
}
