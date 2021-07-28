import Apollo
import Contracts
import Embark
import Flow
import Foundation
import Home
import Offer
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension JourneyPresentation {
	fileprivate var withCompletedToast: Self {
		onPresent {
			Toasts.shared
				.displayToast(
					toast: Toast(
						symbol: .icon(
							hCoreUIAssets
								.circularCheckmark
								.image
						),
						body: L10n
							.movingFlowSuccessToast
					)
				)
		}
	}
}


extension AppJourney {
	static var movingFlow: some JourneyPresentation {
		Journey(
			MovingFlowIntro(),
			style: .detented(.large)
		) { introRoute in
			switch introRoute {
			case .chat:
				Journey(FreeTextChat()).withJourneyDismissButton
			case let .embark(name):
                AppJourney.embark(Embark(name: name)) { offerResult in
					switch offerResult {
					case .chat:
						Journey(
                            FreeTextChat(),
                            style: .detented(.large),
                            options: [.defaults]
                        ).withDismissButton
					case .close:
						DismissJourney()
					case .menu:
						ContinueJourney()
					case .signed:
						Journey(MovingFlowSuccess()) { _ in
							DismissJourney().withCompletedToast
						}
					}
                }
			}
		}
		.withDismissButton
	}
}
