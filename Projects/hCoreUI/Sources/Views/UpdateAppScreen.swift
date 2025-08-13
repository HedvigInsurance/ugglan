import Environment
import SwiftUI
import hCore

public struct UpdateAppScreen: View {
    let onSelected: () -> Void
    let withoutDismissButton: Bool

    public init(
        onSelected: @escaping () -> Void,
        withoutDismissButton: Bool = false
    ) {
        self.onSelected = onSelected
        self.withoutDismissButton = withoutDismissButton
    }

    public var body: some View {
        GenericErrorView(
            title: L10n.embarkUpdateAppTitle,
            description: L10n.embarkUpdateAppBody,
            formPosition: .center
        )
        .hStateViewButtonConfig(buttonsInit)
    }

    private var buttonsInit: StateViewButtonConfig {
        var dismissButton: StateViewButtonConfig.StateViewButton? {
            if withoutDismissButton {
                return nil
            }
            return .init(
                buttonAction: {
                    onSelected()
                }
            )
        }

        return .init(
            actionButton:
                .init(
                    buttonTitle: L10n.embarkUpdateAppButton,
                    buttonAction: {
                        Dependencies.urlOpener.open(Environment.current.appStoreURL)
                        onSelected()
                    }
                ),
            dismissButton: dismissButton
        )
    }
}

#Preview {
    UpdateAppScreen(onSelected: {})
}
