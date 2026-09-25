import SwiftUI
import hCore
import hCoreUI

extension View {
    func paymentMethodTile() -> some View {
        modifier(PaymentMethodTileStyle())
    }
}

private struct PaymentMethodTileStyle: ViewModifier {
    // The dashed border needs a resolved `Color` — hCoreUI's `strokeBorder(_:lineWidth:)`
    // overload for `hColor` takes no `StrokeStyle`.
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.userInterfaceLevel) private var userInterfaceLevel

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
            .hCardShadow()
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusXXL)
                    .stroke(
                        hBorderColor.primary.colorFor(colorScheme, userInterfaceLevel).color,
                        style: StrokeStyle(lineWidth: 1, dash: [2, 2])
                    )
            )
    }
}

struct PaymentMethodPickerGraphic: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let selected: PaymentProvider?

    var body: some View {
        HStack(spacing: .padding16) {
            methodSlot
            dots
            pillow
        }
        .animation(reduceMotion ? .none : .easeInOut, value: selected)
        .accessibilityHidden(true)
    }

    private var methodSlot: some View {
        Group {
            if let provider = selected {
                provider.chooseDefaultImage(size: 74)
            } else {
                hBackgroundColor.primary
                    .frame(width: 74, height: 74)
                    .overlay {
                        hCoreUIAssets.plus.view
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36)
                            .foregroundColor(hSignalColor.Grey.element)
                    }
            }
        }
        .paymentMethodTile()
    }

    private var dots: some View {
        DotsActivityIndicator(.standard)
            .useDarkColor
    }

    private var pillow: some View {
        hCoreUIAssets.bigPillowBlack.view
            .resizable()
            .frame(width: 74, height: 74)
    }
}

#Preview("Nothing picked") {
    PaymentMethodPickerGraphic(selected: nil)
        .padding(.padding32)
}

#Preview("Swish picked") {
    PaymentMethodPickerGraphic(selected: .swish)
        .padding(.padding32)
}
