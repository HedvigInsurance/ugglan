import SwiftUI
import hCore

public struct PriceField: View {
    @ObservedObject var viewModel: PriceFieldViewModel
    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice
    @SwiftUI.Environment(\.hPriceFormatting) var formatting
    
    public init(
        viewModel: PriceFieldViewModel
    ) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        PriceFieldContent(
            viewModel: viewModel,
            title: viewModel.title ?? L10n.tierFlowTotal,
            priceFieldView: priceFieldView
        )
    }
    
    @ViewBuilder
    private var priceFieldView: some View {
        if viewModel.shouldShowCurrentPremium(
            strikeThroughPrice: strikeThroughPrice
        ) {
            PremiumText(
                text: currentPremiumText,
                strikeThrough: true,
                usePrimary: false
            )
        }
        
        VStack(alignment: .trailing, spacing: 0) {
            PremiumText(
                text: newPremiumText,
                strikeThrough: strikeThroughPrice == .crossNewPrice,
                usePrimary: true
            )
            
            if viewModel.shouldShowPreviousPriceLabel(
                strikeThroughPrice: strikeThroughPrice
            ) {
                subTitleField(text: L10n.tierFlowPreviousPrice(viewModel.currentNetPremium?.priceFormat(formatting) ?? ""))
            }
        }
    }
    
    @ViewBuilder
    private func subTitleField(text: String) -> some View {
        hText(text, style: .label)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(hTextColor.Opaque.secondary)
    }
    
    private var currentPremiumText: String {
        viewModel.currentNetPremium?.priceFormat(formatting) ?? ""
    }
    
    private var newPremiumText: String{
        viewModel.newNetPremium?.priceFormat(formatting) ?? viewModel.currentNetPremium?.priceFormat(formatting) ?? ""
    }
}

#Preview {
    hSection {
        PriceField(
            viewModel: .init(
                newNetPremium: .init(amount: "99", currency: "SEK"),
                newGrossPremium: .init(amount: "139", currency: "SEK"),
                currentNetPremium: MonetaryAmount(amount: "49", currency: "SEK"),
            )
        )
        
        PriceField(
            viewModel: .init(
                newNetPremium: .init(amount: "99", currency: "SEK"),
                newGrossPremium: .init(amount: "139", currency: "SEK"),
                currentNetPremium: MonetaryAmount(amount: "49", currency: "SEK")
            )
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
        
        PriceField(
            viewModel: .init(
                newNetPremium: .init(amount: "99", currency: "SEK"),
                newGrossPremium: .init(amount: "139", currency: "SEK"),
                currentNetPremium: nil
            )
        )
        .hWithStrikeThroughPrice(setTo: .crossNewPrice)
        
        PriceField(
            viewModel: .init(
                newNetPremium: .init(amount: "99", currency: "SEK"),
                newGrossPremium: .init(amount: "139", currency: "SEK"),
                currentNetPremium: MonetaryAmount(amount: "49", currency: "SEK"),
                subTitle: "sub title"
            )
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
        
        PriceFieldMultipleRows(
            viewModel: .init(
                newNetPremium: .init(amount: "115", currency: "SEK"),
                newGrossPremium: .init(amount: "139", currency: "SEK"),
                currentNetPremium: MonetaryAmount(amount: "139", currency: "SEK"),
                subTitle: "Changes activates on 16 nov 2025",
                infoButtonDisplayItems: [
                    .init(title: "title", value: "value")
                ]
            )
        )
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
