import SwiftUI
import hCore
import hCoreUI

/// 40 pt black circle with the Hedvig symbol. Black in both light and dark mode.
struct HedvigAvatar: View {
    var body: some View {
        Circle()
            .fill(hFillColor.Opaque.black)
            .frame(width: .padding40, height: .padding40)
            .overlay {
                hCoreUIAssets.helipadBig.view
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(hFillColor.Opaque.white)
                    .frame(width: .padding24, height: .padding24)
            }
            .accessibilityHidden(true)
    }
}

/// Rounded card with a soft shadow, used for the message sections and the email body.
struct MessagesCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                let shape = RoundedRectangle(cornerRadius: .cornerRadiusXXL, style: .continuous)
                ZStack {
                    // Opaque base so the shadow reads under the translucent card fill.
                    shape.fill(hBackgroundColor.primary).hCardShadow()
                    shape.fill(hSurfaceColor.Translucent.highLight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL, style: .continuous))
            .padding(.horizontal, .padding16)
    }
}

enum MessagesGlassButtonStyle {
    /// Filled with the primary fill (black in light, white in dark).
    case prominent
    case regular
}

extension View {
    /// Native Liquid Glass button on iOS 26, an hCoreUI capsule before that. Works for `Button` and `Menu`.
    func messagesGlassButton(_ style: MessagesGlassButtonStyle) -> some View {
        modifier(MessagesGlassButtonModifier(style: style))
    }
}

private struct MessagesGlassButtonModifier: ViewModifier {
    let style: MessagesGlassButtonStyle
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            switch style {
            case .prominent:
                content
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.capsule)
                    // Resolved to a plain Color: hColor's `.tint` sets the accent colour, which glass buttons
                    // in a sheet ignore, so they fell back to system blue.
                    .tint(hFillColor.Opaque.primary.colorFor(colorScheme, .base).color)
            case .regular:
                content
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
            }
        } else {
            content
                .buttonStyle(MessagesCapsuleButtonStyle(style: style))
        }
    }
}

/// Fallback for iOS versions without Liquid Glass.
private struct MessagesCapsuleButtonStyle: ButtonStyle {
    let style: MessagesGlassButtonStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, .padding16)
            .background {
                switch style {
                case .prominent:
                    Capsule().fill(hFillColor.Opaque.primary)
                case .regular:
                    Capsule().fill(hSurfaceColor.Opaque.primary)
                }
            }
            .hShadow(type: .light)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension MessagesGlassButtonStyle {
    @MainActor @hColorBuilder
    var labelColor: some hColor {
        switch self {
        case .prominent: hTextColor.Opaque.negative
        case .regular: hTextColor.Opaque.primary
        }
    }
}
