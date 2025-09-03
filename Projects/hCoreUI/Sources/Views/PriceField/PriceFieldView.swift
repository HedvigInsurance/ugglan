import SwiftUI
import hCore

public struct PriceFieldView: View {
    let viewModel: PriceFieldModel
    @State var isInfoViewPresented: PriceFieldModel?

    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice
    @SwiftUI.Environment(\.hPriceFormatting) var formatting

    public init(
        viewModel: PriceFieldModel
    ) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: .padding2) {
            HStack(alignment: .top) {
                HStack(spacing: .padding4) {
                    titleField
                    infoButton
                }

                Spacer()
                priceFieldView
            }
            subTitleField
        }
        .accessibilityElement(children: .combine)
        .detent(
            item: $isInfoViewPresented
        ) { model in
            PriceBreakdownView(model: model)
        }
    }

    private var titleField: some View {
        hText(viewModel.title ?? L10n.tierFlowTotal)
            .foregroundColor(getTotalColor())
    }

    @ViewBuilder
    private var infoButton: some View {
        if !viewModel.infoButtonDisplayItems.isEmpty {
            hCoreUIAssets.infoFilled.view
                .foregroundColor(hFillColor.Opaque.secondary)
                .onTapGesture {
                    isInfoViewPresented = viewModel
                }
        }
    }

    @ViewBuilder
    private var subTitleField: some View {
        if let subTitle = viewModel.subTitle {
            hText(subTitle, style: .label)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }

    @ViewBuilder
    private var priceFieldView: some View {
        if viewModel.shouldShowPreviousPriceLabel(
            strikeThroughPrice: strikeThroughPrice
        ) {
            PremiumText(
                text: currentPremiumText,
                strikeThrough: strikeThroughPrice == .crossOldPrice,
                usePrimary: false
            )
        }

        VStack(alignment: .trailing, spacing: 0) {
            PremiumText(
                text: newPremiumText,
                strikeThrough: strikeThroughPrice == .crossNewPrice,
                usePrimary: true
            )
        }
    }

    @ViewBuilder
    private func subTitleField(text: String) -> some View {
        hText(text, style: .label)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(hTextColor.Opaque.secondary)
    }

    private var currentPremiumText: String {
        viewModel.initialValue?.priceFormat(formatting) ?? ""
    }

    private var newPremiumText: String {
        viewModel.newValue.priceFormat(formatting)
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

fileprivate struct PremiumText: View {
    let text: String
    let strikeThrough: Bool
    let usePrimary: Bool

    public var body: some View {
        Group {
            if #available(iOS 16.0, *), strikeThrough {
                hText(text)
                    .strikethrough()
                    .foregroundColor(hTextColor.Opaque.secondary)
            } else {
                hText(text)
                    .foregroundColor(newPremiumColor)
            }
        }

        .accessibilityValue(L10n.voiceoverCurrentPrice)
    }

    @hColorBuilder
    private var newPremiumColor: some hColor {
        if usePrimary {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }
}

// MARK: Envionment Keys
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
        environment(\.hWithStrikeThroughPrice, setTo)
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
        environment(\.hPriceFormatting, setTo)
    }
}

extension MonetaryAmount {
    func priceFormat(_ format: PriceFormatting) -> String {
        switch format {
        case .perMonth:
            return formattedAmountPerMonth
        case .month:
            return formattedAmount
        }
    }
}
