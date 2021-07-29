import Foundation
import Presentation

extension AppJourney {
	static var freeTextChat: some JourneyPresentation {
		Journey(FreeTextChat(), style: .detented(.large)).withDismissButton
	}
}
