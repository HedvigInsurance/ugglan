import SwiftUI

struct hButtonFilledBackground: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.hButtonConfigurationType) private var configurationType
    @Environment(\.hUseLightMode) private var useLightMode
    @Environment(\.hButtonIsLoading) private var isLoading
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.userInterfaceLevel) private var userInterfaceLevel

    let configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
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
        return hColor.colorFor(useLightMode ? .light : colorScheme, userInterfaceLevel).color
    }

    private var alertBackgroundColor: some View {
        let activeOpacity: Double = (configuration.isPressed || isEnabled || isLoading) ? 1.0 : 0.2
        return hSignalColor.Red.element.colorFor(useLightMode ? .light : colorScheme, userInterfaceLevel).color
            .opacity(activeOpacity)
    }
}
