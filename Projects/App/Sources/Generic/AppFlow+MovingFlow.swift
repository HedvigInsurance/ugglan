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
        _ presentation: Presentation<Self>,
        @JourneyBuilder offerResultJourney: @escaping (_ result: OfferResult) -> OfferResultJourney
    ) -> some JourneyPresentation {
        presentation.journey { externalRedirect in
            switch externalRedirect {
            case .mailingList:
                ContinueJourney()
            case .close:
                DismissJourney()
            case let .offer(ids):
                Presentation(
                    Offer(
                        offerIDContainer:
                            .exact(
                                ids:
                                    ids,
                                shouldStore:
                                    false
                            ),
                        menu: nil,
                        options: [
                            .menuToTrailing
                        ]
                    )
                )
                .onDismiss {
                    presentation.presentable.goBack()
                }
                .journey { offerResult in
                    offerResultJourney(offerResult)
                }
            }
        }
    }
}

public struct MovingFlowJourney {
	static var journey: some JourneyPresentation {
        Presentation(MovingFlowIntro(), style: .detented(.large), options: [.defaults, .allowSwipeDismissAlways])
            .withDismissButton { introRoute in
				switch introRoute {
				case .chat:
                    Presentation(FreeTextChat()).withDismissButton()
				case let .embark(name):
                    Embark.makeJourney(Presentation(Embark(name: name))) { offerResult in
                        switch offerResult {
                        case .close:
                            DismissJourney()
                        case .signed:
                            DismissJourney().onPresent {
                                Toasts.shared
                                    .displayToast(
                                        toast:
                                            Toast(
                                                symbol:
                                                    .icon(
                                                        hCoreUIAssets
                                                            .circularCheckmark
                                                            .image
                                                    ),
                                                body:
                                                    L10n
                                                    .movingFlowSuccessToast
                                            )
                                    )
                            }
                        }
                    }
				}
			}
	}
}
