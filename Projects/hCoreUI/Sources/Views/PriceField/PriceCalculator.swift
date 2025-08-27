import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

public struct PriceCalculatorModel: Equatable, Identifiable {
    public let id = UUID().uuidString
    let displayItems: [DisplayItem]
    let currentPrice: MonetaryAmount
    let newPrice: MonetaryAmount
    let onDismiss: () -> Void

    public static func == (lhs: PriceCalculatorModel, rhs: PriceCalculatorModel) -> Bool {
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

struct PriceCalculatorView: View {
    let model: PriceCalculatorModel

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding16) {
                    hText(L10n.priceDetailsTitle)

                    VStack(spacing: .padding4) {
                        ForEach(model.displayItems, id: \.title) { item in
                            rowItem(for: item)
                        }
                    }

                    hRowDivider()

                    PriceField(viewModel: .init(newPremium: model.newPrice, currentPremium: model.currentPrice))
                        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
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
                model.onDismiss()
            }
        }
    }

    private func rowItem(for item: PriceCalculatorModel.DisplayItem) -> some View {
        HStack {
            hText(item.title, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
            Spacer()
            hText(item.value, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }
}

#Preview {
    PriceCalculatorView(
        model: .init(
            displayItems: [
                .init(title: "Homeowner Insurance", value: "370 kr/mo"),
                .init(title: "Extended travel 60 days", value: "79 kr/mo"),
                .init(title: "15% bundle discount", value: "-79 kr/mo"),
            ],
            currentPrice: .sek(299),
            newPrice: .sek(229),
            onDismiss: {}
        )
    )
}
