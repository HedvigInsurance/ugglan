import Foundation
import Payment
import Presentation

extension AppJourney {
	static var paymentSetup: some JourneyPresentation {
		Journey(
			PaymentSetup(setupType: .initial, urlScheme: Bundle.main.urlScheme ?? ""),
			style: .detented(.large)
		)
	}
}
