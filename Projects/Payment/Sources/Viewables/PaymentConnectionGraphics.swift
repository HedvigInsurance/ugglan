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

struct StatusBadge: View {
    enum Kind {
        case external
        case success
        case failure
    }

    let kind: Kind

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 24, height: 24)
            .overlay {
                glyph
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12)
                    .foregroundColor(hTextColor.Opaque.negative)
            }
    }

    @MainActor
    @hColorBuilder
    private var color: some hColor {
        switch kind {
        case .external:
            hSignalColor.Blue.element
        case .success:
            hSignalColor.Green.element
        case .failure:
            hSignalColor.Amber.element
        }
    }

    private var glyph: Image {
        switch kind {
        case .external: hCoreUIAssets.arrowNorthEast.view
        case .success: hCoreUIAssets.checkmark.view
        case .failure: hCoreUIAssets.warning.view
        }
    }
}

struct SwishPillow: View {
    private let size: CGFloat = 74

    var body: some View {
        hBackgroundColor.primary
            .frame(width: size, height: size)
            .overlay {
                hCoreUIAssets.swish.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 39)
            }
            .paymentMethodTile()
    }
}

struct PaymentConnectionPairGraphic: View {
    let provider: PaymentProvider
    let outcome: StatusBadge.Kind

    var body: some View {
        HStack(spacing: .padding16) {
            provider.chooseDefaultImage(size: 74)
                .paymentMethodTile()
            DotsActivityIndicator(.standard, animated: false)
                .useDarkColor
            hCoreUIAssets.bigPillowBlack.view
                .resizable()
                .frame(width: 74, height: 74)
                .overlay(alignment: .topTrailing) {
                    StatusBadge(kind: outcome)
                        .offset(x: .padding8, y: -.padding8)
                }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: .padding32) {
        PaymentMethodPickerGraphic(selected: nil)
        PaymentMethodPickerGraphic(selected: .swish)
        SwishPillow()
        PaymentConnectionPairGraphic(provider: .swish, outcome: .success)
        PaymentConnectionPairGraphic(provider: .swish, outcome: .failure)
    }
    .padding(.padding32)
}
