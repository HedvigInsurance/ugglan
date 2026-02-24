import SwiftUI

public enum hButtonConfigurationType: Sendable, CaseIterable {
    case primary
    case primaryAlt
    case secondary
    case secondaryAlt
    case ghost
    case alert

    @MainActor
    var hButtonColorSet: hButtonColor {
        switch self {
        case .primary: return Primary()
        case .primaryAlt: return PrimaryAlt()
        case .secondary: return Secondary()
        case .secondaryAlt: return SecondaryAlt()
        case .ghost: return Ghost()
        case .alert: fatalError("Alert type should not be passed to regularBackgroundColor.")
        }
    }

    func shouldUseDark(for schema: ColorScheme) -> Bool {
        switch schema {
        case .dark:
            return self != .primary && self != .primaryAlt
        case .light:
            return self != .primary
        @unknown default:
            return false
        }
    }
}

public struct ButtonFilledStyle: SwiftUI.ButtonStyle {
    @Environment(\.hButtonWithBorder) var withBorder
    var size: hButtonSize

    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
        }
        .buttonSizeModifier(size)
        .background(hButtonFilledBackground(configuration: configuration))
        .buttonCornerModifier(size, withBorder: withBorder)
    }

    // content
    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
        @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
        @Environment(\.hUseLightMode) var hUseLightMode
        @Environment(\.hUseButtonTextColor) var buttonTextColor
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.userInterfaceLevel) var userInterfaceLevel

        var configuration: Configuration

        @hColorBuilder var foregroundHColor: some hColor {
            if buttonTextColor == .red {
                hSignalColor.Red.element
            } else if !isEnabled {
                hTextColor.Opaque.disabled
            } else {
                switch hButtonConfigurationType {
                case .primary:
                    hTextColor.Opaque.primary.inverted
                case .primaryAlt:
                    hTextColor.Opaque.primary.colorFor(.light, .base)
                default:
                    hTextColor.Opaque.primary
                }
            }
        }

        var body: some View {
            let resolvedColor = foregroundHColor.colorFor(colorScheme, userInterfaceLevel).color
            let label = configuration.label
                .foregroundColor(resolvedColor)
                .animation(.default, value: isEnabled)

            LoaderOrContent() {
                if hUseLightMode {
                    label
                        .colorScheme(.light)
                } else {
                    label
                }
            }
        }
    }
}
