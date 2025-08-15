import SwiftUI
import hCore

public struct PriceField: View {
    @StateObject var viewModel: PriceFieldViewModel

    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice
    @SwiftUI.Environment(\.hPriceFormatting) var formatting
    @SwiftUI.Environment(\.hPriceFieldFormat) var fieldFormat

    public init(
        viewModel: PriceFieldViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        viewModel.setEnvironmentVariables(
            strikeThroughPrice: strikeThroughPrice,
            formatting: formatting,
            fieldFormat: fieldFormat
        )
        return Group {
            if fieldFormat == .multipleRow {
                multipleRowContent
            } else {
                mainContent()
            }
        }
        .detent(
            item: $viewModel.isInfoViewPresented
        ) { model in
            PriceCalculatorView(model: model)
        }
    }

    @ViewBuilder
    private var multipleRowContent: some View {
        hSection {
            hRow {
                mainContent(for: .currentPrice)
            }
            hRow {
                mainContent(
                    for: .newPrice,
                    withInfoButton: viewModel.withInfoButton
                )
            }
        }
        .hWithoutHorizontalPadding([.all])
        .sectionContainerStyle(.transparent)
    }

    private func mainContent(for priceType: PriceType? = nil, withInfoButton: Bool = false) -> some View {
        VStack(spacing: .padding2) {
            HStack(alignment: .top) {
                HStack(spacing: .padding4) {
                    titleField(for: priceType)
                    if withInfoButton {
                        hCoreUIAssets.infoFilled.view
                            .foregroundColor(hFillColor.Opaque.secondary)
                            .onTapGesture {
                                viewModel.isInfoViewPresented = .init(
                                    displayItems: [
                                        .init(title: "Homeowner Insurance", value: "370 kr/mo"),
                                        .init(title: "Extended travel 60 days", value: "79 kr/mo"),
                                        .init(title: "15% bundle discount", value: "-79 kr/mo"),
                                    ],
                                    currentPrice: viewModel.currentPremium ?? .sek(0),
                                    newPrice: viewModel.newPremium ?? .sek(0),
                                    onDismiss: {
                                        viewModel.isInfoViewPresented = nil
                                    }
                                )
                            }
                    }
                }
                Spacer()
                priceFieldView(
                    showCurrentPremium: priceType != .newPrice,
                    showNewPremium: priceType != .currentPrice
                )
            }
            if priceType != .currentPrice, let subTitle = viewModel.subTitle {
                subTitleField(text: subTitle)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func titleField(for priceType: PriceType?) -> some View {
        var text: String {
            if let priceType {
                return priceType == .currentPrice ? L10n.pricePreviousPrice : L10n.priceNewPrice
            }
            return viewModel.title ?? L10n.tierFlowTotal
        }
        return hText(text)
            .foregroundColor(getTotalColor())
    }

    @ViewBuilder
    private func subTitleField(text: String) -> some View {
        hText(text, style: .label)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(hTextColor.Opaque.secondary)
    }

    @ViewBuilder
    private func priceFieldView(
        showCurrentPremium: Bool = true,
        showNewPremium: Bool = true
    ) -> some View {
        if viewModel.shouldShowCurrentPremium(showCurrentPremium) {
            if #available(iOS 16.0, *), fieldFormat != .multipleRow {
                currentPremiumView
                    .strikethrough()
                    .accessibilityValue(L10n.voiceoverCurrentPrice)
            } else {
                currentPremiumView
            }
        }

        VStack(alignment: .trailing, spacing: 0) {
            if viewModel.shouldStrikeThroughNewPremium(showNewPremium) {
                if #available(iOS 16.0, *) {
                    newPremiumView()
                        .strikethrough()
                        .accessibilityValue(
                            L10n.voiceoverCurrentPrice
                        )
                } else {
                    newPremiumView()
                        .accessibilityValue(
                            L10n.ReferralsActive.Your.New.Price.title
                        )
                }
            } else if showNewPremium {
                newPremiumView(usePrimary: true)
            }

            if viewModel.shouldShowPreviousPriceLabel {
                subTitleField(text: L10n.tierFlowPreviousPrice(viewModel.currentPremium?.priceFormat(formatting) ?? ""))
            }
        }
    }

    private var currentPremiumView: some View {
        hText(viewModel.currentPremium?.priceFormat(formatting) ?? "")
            .foregroundColor(currentPremiumColor)
    }

    private func newPremiumView(usePrimary: Bool = false) -> some View {
        hText(viewModel.newPremium?.priceFormat(formatting) ?? viewModel.currentPremium?.priceFormat(formatting) ?? "")
            .foregroundColor(newPremiumColor(usePrimary: usePrimary))
    }

    @hColorBuilder
    private var currentPremiumColor: some hColor {
        switch fieldFormat {
        case .multipleRow:
            hTextColor.Opaque.primary
        case .default:
            hTextColor.Opaque.secondary
        }
    }

    @hColorBuilder
    private func newPremiumColor(usePrimary: Bool = false) -> some hColor {
        if usePrimary {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
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

    enum PriceType {
        case currentPrice
        case newPrice
    }
}

public class PriceFieldViewModel: ObservableObject {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?
    let title: String?
    let subTitle: String?
    var strikeThroughPrice: StrikeThroughPriceType = .none
    var formatting: PriceFormatting = .perMonth
    var fieldFormat: PriceFieldFormat = .default
    var withInfoButton: Bool
    @Published var isInfoViewPresented: PriceCalculatorModel?

    public init(
        newPremium: MonetaryAmount?,
        currentPremium: MonetaryAmount?,
        title: String? = nil,
        subTitle: String? = nil,
        withInfoButton: Bool = false
    ) {
        self.newPremium = newPremium
        self.currentPremium = currentPremium
        self.title = title
        self.subTitle = subTitle
        self.withInfoButton = withInfoButton
    }

    func setEnvironmentVariables(
        strikeThroughPrice: StrikeThroughPriceType,
        formatting: PriceFormatting,
        fieldFormat: PriceFieldFormat
    ) {
        self.strikeThroughPrice = strikeThroughPrice
        self.formatting = formatting
        self.fieldFormat = fieldFormat
    }

    func shouldShowCurrentPremium(_ showCurrentPremium: Bool) -> Bool {
        let hasStrikeThrough = strikeThroughPrice != .none && fieldFormat != .multipleRow
        let noStrikeThroughMultipleRow = strikeThroughPrice == .none && fieldFormat == .multipleRow
        return (hasStrikeThrough || noStrikeThroughMultipleRow) && newPremium != currentPremium && showCurrentPremium
    }

    func shouldStrikeThroughNewPremium(_ showNewPremium: Bool) -> Bool {
        strikeThroughPrice == .crossNewPrice && fieldFormat != .multipleRow && showNewPremium
    }

    var shouldShowPreviousPriceLabel: Bool {
        if let currentPremium, let newPremium {
            return newPremium != currentPremium && strikeThroughPrice != .crossOldPrice && fieldFormat != .multipleRow
        }
        return false
    }
}

#Preview {
    hSection {
        PriceField(
            viewModel: .init(
                newPremium: .init(amount: "99", currency: "SEK"),
                currentPremium: MonetaryAmount(amount: "49", currency: "SEK"),
            )
        )

        PriceField(
            viewModel: .init(
                newPremium: .init(amount: "99", currency: "SEK"),
                currentPremium: MonetaryAmount(amount: "49", currency: "SEK")
            )
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)

        PriceField(
            viewModel: .init(
                newPremium: .init(amount: "99", currency: "SEK"),
                currentPremium: nil
            )
        )
        .hWithStrikeThroughPrice(setTo: .crossNewPrice)

        PriceField(
            viewModel: .init(
                newPremium: .init(amount: "99", currency: "SEK"),
                currentPremium: MonetaryAmount(amount: "49", currency: "SEK"),
                subTitle: "sub title"
            )
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)

        PriceField(
            viewModel: .init(
                newPremium: .init(amount: "115", currency: "SEK"),
                currentPremium: MonetaryAmount(amount: "139", currency: "SEK"),
                subTitle: "Changes activates on 16 nov 2025",
                withInfoButton: true
            )
        )
        .hPriceFieldFormat(.multipleRow)
        .hWithoutHorizontalPadding(.all)
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
        environment(\.hWithStrikeThroughPrice, setTo)
    }
}

private struct EnvironmentHPriceFieldFormat: EnvironmentKey {
    static let defaultValue: PriceFieldFormat = .default
}

public enum PriceFieldFormat: Sendable {
    case `default`
    case multipleRow
}

extension EnvironmentValues {
    public var hPriceFieldFormat: PriceFieldFormat {
        get { self[EnvironmentHPriceFieldFormat.self] }
        set { self[EnvironmentHPriceFieldFormat.self] = newValue }
    }
}

extension View {
    public func hPriceFieldFormat(_ format: PriceFieldFormat) -> some View {
        environment(\.hPriceFieldFormat, format)
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
