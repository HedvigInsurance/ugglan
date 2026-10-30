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

struct PaymentConnectionGraphic: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var direction: PaymentDirection = .payin
    let provider: PaymentProvider?
    /// `nil` while the user is still picking (animated dots, no badge);
    /// non-nil once the connection has a result, badging the trailing tile.
    var outcome: StatusBadge.Kind? = nil

    var body: some View {
        HStack(spacing: 0) {
            switch direction {
            case .payin:
                methodSlot.collapsed(provider == nil)
                dots.collapsed(provider == nil)
                badged(pillow)
            case .payout:
                pillow
                dots.collapsed(provider == nil)
                badged(methodSlot).collapsed(provider == nil)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut, value: provider)
        .animation(reduceMotion ? .none : .easeInOut, value: outcome)
        .accessibilityHidden(true)
        .geometryGroup()
    }

    private var methodSlot: some View {
        ZStack {
            methodContent
        }
        .frame(width: 74, height: 74)
        .paymentMethodTile()
        .geometryGroup()
    }

    @ViewBuilder
    private var methodContent: some View {
        if let provider {
            provider.chooseDefaultImage(size: 74)
        } else {
            hBackgroundColor.primary
                .frame(width: 74, height: 74)
                .overlay {
                    hCoreUIAssets.plus.view
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 37)
                        .foregroundColor(hSignalColor.Grey.element)
                }
        }
    }

    private var dots: some View {
        DotsActivityIndicator(.standard, animated: outcome == nil)
            .useDarkColor
            .padding(.horizontal, .padding16)
    }

    private var pillow: some View {
        hCoreUIAssets.bigPillowBlack.view
            .resizable()
            .frame(width: 74, height: 74)
    }

    private func badged(_ tile: some View) -> some View {
        tile.overlay(alignment: .topTrailing) {
            if let outcome {
                StatusBadge(kind: outcome)
                    .offset(x: .padding8, y: -.padding8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

extension View {
    fileprivate func collapsed(_ isCollapsed: Bool) -> some View {
        CollapsingLayout(fraction: isCollapsed ? 0 : 1) { self }
            .opacity(isCollapsed ? 0 : 1)
            .scaleEffect(isCollapsed ? 0.5 : 1)
    }
}

/// Takes its content's ideal width scaled by `fraction`. A `.frame(width:)` can't animate to and from
/// `nil`, so this lets a view collapse smoothly without hard-coding its width.
private struct CollapsingLayout: Layout {
    var fraction: CGFloat

    var animatableData: CGFloat {
        get { fraction }
        set { fraction = newValue }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let size = subviews.first?.sizeThatFits(.unspecified) ?? .zero
        return CGSize(width: size.width * fraction, height: size.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: .unspecified)
    }
}

struct StatusBadge: View {
    enum Kind {
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
                    .foregroundColor(hTextColor.Opaque.negative)
            }
    }

    @MainActor
    @hColorBuilder
    private var color: some hColor {
        switch kind {
        case .success:
            hSignalColor.Green.element
        case .failure:
            hSignalColor.Amber.element
        }
    }

    @ViewBuilder
    private var glyph: some View {
        switch kind {
        case .success: icon(hCoreUIAssets.checkmark.view)
        case .failure: hText("!", style: .label).hWithoutFontMultiplier.accessibilityHidden(true)
        }
    }

    private func icon(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18)
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

#Preview {
    VStack(spacing: .padding32) {
        PaymentConnectionGraphic(provider: nil)
        PaymentConnectionGraphic(provider: .swish)
        SwishPillow()
        PaymentConnectionGraphic(provider: .swish, outcome: .success)
        PaymentConnectionGraphic(provider: .swish, outcome: .failure)
        PaymentConnectionGraphic(direction: .payout, provider: .nordea)
        PaymentConnectionGraphic(direction: .payout, provider: .nordea, outcome: .success)
    }
    .padding(.padding32)
}

#Preview("Provider set after 1 s") {
    @Previewable @State var provider: PaymentProvider? = nil
    VStack {
        PaymentConnectionGraphic(provider: provider)
            .padding(.padding32)
            .task {
                try? await Task.sleep(for: .seconds(1))
                provider = .swish
                try? await Task.sleep(for: .seconds(1))
                provider = nil
            }
        Spacer()
    }
}
