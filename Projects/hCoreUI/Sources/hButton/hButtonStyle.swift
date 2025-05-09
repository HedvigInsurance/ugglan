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

    // TODO: IS THIS USED?
    func shouldUseDark(for schema: ColorScheme) -> Bool {
        switch schema {
        case .dark:
            switch self {
            case .primary, .primaryAlt:
                return false
            case .secondary, .secondaryAlt, .ghost, .alert:
                return true
            }
        case .light:
            switch self {
            case .primary:
                return false
            default:
                return true
            }
        @unknown default:
            return false
        }
    }
}

public struct ButtonFilledStyle: SwiftUI.ButtonStyle {
    var size: hButtonSize
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType

    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
        }
        .buttonSizeModifier(size)
        .background(ButtonFilledStandardBackground(configuration: configuration))
        .buttonCornerModifier(size)
    }

    //content
    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
        @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
        @Environment(\.hUseLightMode) var hUseLightMode
        @Environment(\.hUseButtonTextColor) var buttonTextColor

        var configuration: Configuration

        @hColorBuilder var foregroundColor: some hColor {
            if buttonTextColor == .red {
                hSignalColor.Red.element
            } else {
                if !isEnabled {
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
        }

        var body: some View {
            LoaderOrContent(color: foregroundColor) {
                if hUseLightMode {
                    configuration.label
                        .foregroundColor(
                            foregroundColor
                        )
                        .colorScheme(.light)
                } else {
                    configuration.label
                        .foregroundColor(
                            foregroundColor
                        )
                }
            }
        }
    }
}
