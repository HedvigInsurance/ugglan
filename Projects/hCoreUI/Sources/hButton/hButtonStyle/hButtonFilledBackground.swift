import SwiftUI

struct hButtonFilledBackground: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.hButtonConfigurationType) private var configurationType
    @Environment(\.hUseLightMode) private var useLightMode
    @Environment(\.hButtonIsLoading) private var isLoading

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

    @ViewBuilder
    private var regularBackgroundColor: some View {
        let colorSet = configurationType.hButtonColorSet

        if configuration.isPressed {
            colorSet.resting.asAnyView
        } else if isEnabled || isLoading {
            colorSet.resting.asAnyView
        } else {
            colorSet.disabled.asAnyView
        }
    }

    @ViewBuilder
    private var alertBackgroundColor: some View {
        if configuration.isPressed || isEnabled || isLoading {
            hSignalColor.Red.element
        } else {
            hSignalColor.Red.element.opacity(0.2)
        }
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
