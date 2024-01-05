import hCore
import hCoreUI
import Presentation

extension AppJourney {
    static var updateApp: some JourneyPresentation {
        HostingJourney(
            rootView: UpdateAppScreen(
                onSelected: {
            },
                withoutDismissButton: true
            )
        )
    }
}
