import Presentation
import SwiftUI
import hCore
import hGraphQL

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
            buttons: buttonsInit
        )
    }

    private var buttonsInit: ErrorViewButtonConfig {

        var dismissButton: ErrorViewButtonConfig.ErrorViewButton? {
            if withoutDismissButton {
                return nil
            }
            return .init(
                buttonTitle: L10n.generalCloseButton,
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
                        UIApplication.shared.open(Environment.current.appStoreURL)
                        onSelected()
                    }
                ),
            dismissButton: dismissButton
        )
    }
}

#Preview{
    UpdateAppScreen(onSelected: {})
}

extension UpdateAppScreen {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            rootView: UpdateAppScreen(
                onSelected: {
                },
                withoutDismissButton: true
            )
        )
    }
}
