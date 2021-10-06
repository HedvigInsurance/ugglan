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
                AppJourney.freeTextChat(style: .default).withJourneyDismissButton
            case let .embark(name):
                AppJourney.embark(Embark(name: name), storeOffer: false) { offerResult in
                    switch offerResult {
                    case .chat:
                        AppJourney.freeTextChat().withDismissButton
                    case .close:
                        DismissJourney()
                    case .menu:
                        ContinueJourney()
                    case let .signed(_, startDates):
                        Journey(MovingFlowSuccess(startDate: startDates.first?.value)) { _ in
                            DismissJourney().withCompletedToast
                        }
                        .hidesBackButton.withJourneyDismissButton
                    }
                }
            }
        }
        .withDismissButton
    }
}
