import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

struct PriceBreakdownView: View {
    let model: PriceBreakdownViewModel
    private let router = Router()

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding16) {
                    hText(L10n.priceDetailsTitle)
                    displayItemsView
                    hRowDivider()
                    priceFieldView
                }
                .padding(.top, .padding32)
                .padding(.horizontal, .padding8)
            }
            .sectionContainerStyle(.transparent)
            .hWithoutHorizontalPadding([.divider])
            .padding(.bottom, .padding24)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hCloseButton {
                router.dismiss()
            }
        }
        .embededInNavigation(router: router, options: [.navigationBarHidden], tracking: self)
    }

    private var displayItemsView: some View {
        VStack(spacing: .padding4) {
            ForEach(model.displayItems, id: \.title) { item in
                rowItem(for: item)
            }
        }
    }

    private var priceFieldView: some View {
        PriceField(
            viewModel: .init(
                newPremium: model.finalPrice,
                currentPremium: model.initialPrice
            )
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
    }

    private func rowItem(for item: PriceBreakdownViewModel.DisplayItem) -> some View {
        HStack {
            hText(item.title, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
            Spacer()
            hText(item.value, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }
}

public struct PriceBreakdownViewModel: Equatable, Identifiable {
    public let id = UUID().uuidString
    let displayItems: [DisplayItem]
    let initialPrice: MonetaryAmount
    let finalPrice: MonetaryAmount

    public static func == (lhs: PriceBreakdownViewModel, rhs: PriceBreakdownViewModel) -> Bool {
        lhs.id == rhs.id
    }

    public struct DisplayItem {
        let title: String
        let value: String

        public init(
            title: String,
            value: String
        ) {
            self.title = title
            self.value = value
        }
    }
}

extension PriceBreakdownView: TrackingViewNameProtocol {
    var nameForTracking: String {
        String.init(describing: PriceBreakdownView.self)
    }
}

#Preview {
    PriceBreakdownView(
        model: .init(
            displayItems: [
                .init(title: "Homeowner Insurance", value: "370 kr/mo"),
                .init(title: "Extended travel 60 days", value: "79 kr/mo"),
                .init(title: "15% bundle discount", value: "-79 kr/mo"),
            ],
            initialPrice: .sek(299),
            finalPrice: .sek(229)
        )
    )
}
