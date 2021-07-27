import Foundation
import Presentation
import hCore

extension MenuChildAction {
	var journey: some JourneyPresentation {
		GroupJourney {
			switch self {
			case MenuChildAction.appInformation:
				Journey(
					AppInfo(type: .appInformation),
					style: .detented(.large),
					options: [
						.defaults, .largeTitleDisplayMode(.always), .prefersLargeTitles(true),
					]
				)
				.withDismissButton
			case MenuChildAction.appSettings:
				Journey(
					AppInfo(type: .appSettings),
					style: .detented(.large),
					options: [
						.defaults, .largeTitleDisplayMode(.always), .prefersLargeTitles(true),
					]
				)
				.withDismissButton
			case MenuChildAction.login:
				Journey(Login(), style: .detented(.large))
			default:
				ContinueJourney()
			}
		}
	}
}
