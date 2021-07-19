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

extension Embark {
	static func makeJourney<OfferResultJourney: JourneyPresentation>(
		_ embark: Embark,
		@JourneyBuilder offerResultJourney: @escaping (_ result: OfferResult) -> OfferResultJourney
	) -> some JourneyPresentation {
		Journey(embark) { externalRedirect in
			switch externalRedirect {
			case .mailingList:
				ContinueJourney()
			case .close:
				DismissJourney()
			case let .offer(ids):
				Journey(
					Offer(
						offerIDContainer:
							.exact(
								ids:
									ids,
								shouldStore:
									false
							),
                        menu: embark.menu,
						options: [
							.menuToTrailing
						]
					)
				) { offerResult in
					offerResultJourney(offerResult)
				}
				.onDismiss {
					embark.goBack()
				}
			}
        }
    }
}

public struct MovingFlowJourney {
	static var journey: some JourneyPresentation {
		Journey(
			MovingFlowIntro(),
			style: .detented(.large),
			options: [.defaults, .allowSwipeDismissAlways, .autoPop]
		) { introRoute in
			switch introRoute {
			case .chat:
				Journey(FreeTextChat()).withDismissButton
			case let .embark(name):
				Embark.makeJourney(Embark(name: name)) { offerResult in
					switch offerResult {
                    case .chat:
                        Journey(FreeTextChat(), style: .detented(.large), options: [.defaults]).withDismissButton
					case .close:
						DismissJourney()
					case .signed:
						DismissJourney()
							.onPresent {
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
			}
		}
		.withDismissButton
	}
}
