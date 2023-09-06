import Foundation
import Presentation
import hCore
import Profile

extension MenuChildAction {
    var journey: some JourneyPresentation {
        GroupJourney {
            switch self {
            case MenuChildAction.appInformation:
                HostingJourney(
                    rootView: AppInfoView(),
                    style: .detented(.large)
                )
                .withDismissButton
            case MenuChildAction.login:
                AppJourney.login
            default:
                ContinueJourney()
            }
        }
    }
}
