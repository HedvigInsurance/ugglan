import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
	static var claimsJourney: some JourneyPresentation {
		Journey(
			HonestyPledge(),
			style: .detented(.scrollViewContentSize),
			options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
		) { _ in
			Journey(
				ClaimsAskForPushnotifications(),
				style: .detented(.large, modally: false)
			) { _ in
				Journey(
					ClaimsChat()
				)
				.withJourneyDismissButton
			}
			.withJourneyDismissButton
		}
		.withDismissButton
	}
}
