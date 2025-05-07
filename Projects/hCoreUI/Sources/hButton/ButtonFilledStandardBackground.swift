import SwiftUI

struct ButtonFilledStandardBackground: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
    var configuration: SwiftUI.ButtonStyle.Configuration
    @Environment(\.hUseLightMode) var hUseLightMode
    @Environment(\.hButtonIsLoading) var isLoading

    var body: some View {
        backgroundColorView
            .if(hUseLightMode) { view in
                view.colorScheme(.light)
            }
    }

    @ViewBuilder
    private var backgroundColorView: some View {
        switch hButtonConfigurationType {
        case .alert:
            alertBackgroundColor
        default:
            regularBackgroundColor(for: hButtonConfigurationType)
        }
    }

    @ViewBuilder
    private func regularBackgroundColor(for type: hButtonConfigurationType) -> some View {
        let colorSet = hButtonConfigurationType.hButtonColorSet

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
    /// Conditional modifier application.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
