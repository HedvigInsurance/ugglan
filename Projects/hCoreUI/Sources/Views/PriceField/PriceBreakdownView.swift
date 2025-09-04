import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

struct PriceBreakdownView: View {
    let model: PriceFieldModel
    private let router = Router()

    var body: some View {
        hForm {
            hSection {
                mainContent
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

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: .padding16) {
            hText(L10n.priceDetailsTitle)
            displayItemsView
            hRowDivider()
            priceField
        }
        .padding(.top, .padding32)
        .padding(.horizontal, .padding8)
    }

    private var displayItemsView: some View {
        VStack(spacing: .padding4) {
            ForEach(model.infoButtonDisplayItems, id: \.title) { item in
                rowItem(for: item)
            }
        }
    }

    private var priceField: some View {
        PriceField(
            viewModel: model.withoutDisplayItems()
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
    }

    private func rowItem(for item: PriceFieldModel.DisplayItem) -> some View {
        HStack {
            hText(item.title, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
            Spacer()
            hText(item.value, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
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
            initialValue: .sek(299),
            newValue: .sek(229),
            infoButtonDisplayItems: [
                .init(title: "Homeowner Insurance", value: "370 kr/mo"),
                .init(title: "Extended travel 60 days", value: "79 kr/mo"),
                .init(title: "15% bundle discount", value: "-79 kr/mo"),
            ]
        )
    )
}

extension View {
    public func showPriceBreakdown(for model: Binding<PriceFieldModel?>) -> some View {
        self.modifier(PriceBreakdownViewDetent(model: model))
    }
}

struct PriceBreakdownViewDetent: ViewModifier {
    @Binding var model: PriceFieldModel?

    func body(content: Content) -> some View {
        content.detent(item: $model) { model in
            PriceBreakdownView(model: model)
        }
    }
}
