import SwiftUI
import hCore

public struct PriceFieldContent<PriceFieldView: View>: View {
    let title: String
    let includeSubTitle: Bool
    let infoButtonDisplayItems: [PriceBreakdownViewModel.DisplayItem]?
    let priceFieldView: PriceFieldView

    @ObservedObject var viewModel: PriceFieldViewModel
    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice

    init(
        viewModel: PriceFieldViewModel,
        title: String,
        includeSubTitle: Bool? = true,
        priceFieldView: PriceFieldView,
        infoButtonDisplayItems: [PriceBreakdownViewModel.DisplayItem]? = nil
    ) {
        self.viewModel = viewModel
        self.title = title
        self.includeSubTitle = includeSubTitle ?? true
        self.priceFieldView = priceFieldView
        self.infoButtonDisplayItems = infoButtonDisplayItems
    }

    public var body: some View {
        VStack(spacing: .padding2) {
            HStack(alignment: .top) {
                HStack(spacing: .padding4) {
                    titleField
                    if let infoButtonDisplayItems {
                        hCoreUIAssets.infoFilled.view
                            .foregroundColor(hFillColor.Opaque.secondary)
                            .onTapGesture {
                                viewModel.isInfoViewPresented = .init(
                                    displayItems: infoButtonDisplayItems,
                                    initialPrice: viewModel.newGrossPremium ?? .sek(0),
                                    finalPrice: viewModel.newNetPremium ?? .sek(0)
                                )
                            }
                    }
                }

                Spacer()
                priceFieldView
            }
            subTitleField
        }
        .accessibilityElement(children: .combine)
    }

    private var titleField: some View {
        hText(title)
            .foregroundColor(getTotalColor())
    }

    @ViewBuilder
    private var subTitleField: some View {
        if let subTitle = viewModel.subTitle, includeSubTitle {
            hText(subTitle, style: .label)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(hTextColor.Opaque.secondary)
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

public struct PremiumText: View {
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
