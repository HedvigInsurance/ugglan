import SwiftUI
import hCore

public struct PriceFieldMultipleRows: View {
    @ObservedObject var viewModel: PriceFieldViewModel
    @SwiftUI.Environment(\.hWithStrikeThroughPrice) var strikeThroughPrice
    @SwiftUI.Environment(\.hPriceFormatting) var formatting

    public init(
        viewModel: PriceFieldViewModel
    ) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .detent(
                item: $viewModel.isInfoViewPresented
            ) { model in
                PriceBreakdownView(model: model)
            }
    }

    @ViewBuilder
    private var content: some View {
        hSection {
            hRow {
                mainContent(for: .currentPrice)
            }
            hRow {
                mainContent(
                    for: .newPrice,
                    infoButtonDisplayItems: viewModel.infoButtonDisplayItems
                )
            }
        }
        .hWithoutHorizontalPadding([.all])
        .sectionContainerStyle(.transparent)
    }

    private func mainContent(
        for priceType: PriceType? = nil,
        infoButtonDisplayItems: [PriceBreakdownViewModel.DisplayItem]? = nil
    ) -> some View {
        PriceFieldContent(
            viewModel: viewModel,
            title: getTitle(for: priceType),
            includeSubTitle: priceType != .currentPrice,
            priceFieldView: priceFieldView(
                showCurrentPremium: priceType != .newPrice,
                showNewPremium: priceType != .currentPrice
            ),
            infoButtonDisplayItems: infoButtonDisplayItems
        )
    }

    private func getTitle(for priceType: PriceType?) -> String {
        if let priceType {
            return priceType == .currentPrice ? L10n.pricePreviousPrice : L10n.priceNewPrice
        }
        return viewModel.title ?? L10n.tierFlowTotal
    }

    @ViewBuilder
    private func priceFieldView(
        showCurrentPremium: Bool = true,
        showNewPremium: Bool = true
    ) -> some View {
        if viewModel.shouldShowCurrentPremium(
            showCurrentPremium,
            strikeThroughPrice: strikeThroughPrice,
            multipleRows: true
        ) {
            currentPremiumView
        }

        if showNewPremium {
            newPremiumView
        }
    }

    private var currentPremiumView: some View {
        hText(viewModel.currentNetPremium?.priceFormat(formatting) ?? "")
    }

    private var newPremiumView: some View {
        hText(
            viewModel.newNetPremium?.priceFormat(formatting) ?? viewModel.currentNetPremium?.priceFormat(formatting)
                ?? ""
        )
    }

    enum PriceType {
        case currentPrice
        case newPrice
    }
}
