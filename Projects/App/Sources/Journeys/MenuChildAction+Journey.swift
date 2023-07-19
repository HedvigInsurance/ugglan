import Foundation
import Presentation
import hCore

extension MenuChildAction {
    var journey: some JourneyPresentation {
        GroupJourney {
            switch self {
            case MenuChildAction.appInformation:
                Journey(
                    AppInfo(),
                    style: .detented(.large),
                    options: [
                        .defaults, .largeTitleDisplayMode(.always), .prefersLargeTitles(true),
                    ]
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
