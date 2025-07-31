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
    var size: hButtonSize

    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
        }
        .buttonSizeModifier(size)
        .background(hButtonFilledBackground(configuration: configuration))
        .buttonCornerModifier(size)
    }

    // content
    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
        @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
        @Environment(\.hUseLightMode) var hUseLightMode
        @Environment(\.hUseButtonTextColor) var buttonTextColor

        var configuration: Configuration

        @hColorBuilder var foregroundColor: some hColor {
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
            let label = configuration.label
                .foregroundColor(foregroundColor)

            LoaderOrContent(color: foregroundColor) {
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
