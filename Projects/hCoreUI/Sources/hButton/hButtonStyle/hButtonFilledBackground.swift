import SwiftUI

struct hButtonFilledBackground: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.hButtonConfigurationType) private var configurationType
    @Environment(\.hUseLightMode) private var useLightMode
    @Environment(\.hButtonIsLoading) private var isLoading
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.userInterfaceLevel) private var userInterfaceLevel

    var configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
        backgroundColorView
            .applyLightModeIfNeeded(useLightMode)
    }

    @ViewBuilder
    private var backgroundColorView: some View {
        switch configurationType {
        case .alert:
            alertBackgroundColor
        default:
            regularBackgroundColor
        }
    }

    private var regularBackgroundColor: some View {
        let colorSet = configurationType.hButtonColorSet
        let hColor = (isEnabled || isLoading || configuration.isPressed) ? colorSet.resting : colorSet.disabled
        return hColor.colorFor(colorScheme, userInterfaceLevel).color
    }

    private var alertBackgroundColor: some View {
        let activeOpacity: Double = (configuration.isPressed || isEnabled || isLoading) ? 1.0 : 0.2
        return hSignalColor.Red.element.colorFor(colorScheme, userInterfaceLevel).color.opacity(activeOpacity)
    }
}

extension View {
    @ViewBuilder
    fileprivate func applyLightModeIfNeeded(_ useLightMode: Bool) -> some View {
        if useLightMode {
            colorScheme(.light)
        } else {
            self
        }
    }
}
