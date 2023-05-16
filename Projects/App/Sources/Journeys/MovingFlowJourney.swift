import Apollo
import Contracts
import Embark
import Flow
import Foundation
import Home
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
        HostingJourney(
            ContractStore.self,
            // LoadingViewWithContent(.startClaim) { MovingFlowHousingType() }
            rootView: MovingFlowHousingType(),
            style: .detented(.large, modally: false)
        ) { action in
            DismissJourney()
            //            if case .navigationActionMovingFlow = action {
            ////                MovingFlowJourneyNew.getScreenForAction(for: action, withHidesBack: true)
            //                MovingFlowJourneyNew.getMovingFlowScreen(for: action)
            //            } else {
            ////                MovingFlowJourneyNew.getScreenForAction(for: action, withHidesBack: true)
            //                MovingFlowJourneyNew.getMovingFlowScreen(for: action)
            //            }
        }
    }

    static var movingFlowEmbark: some JourneyPresentation {
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
                    case let .signed(_, startDates), let .signedQuoteCart(_, startDates):
                        Journey(MovingFlowSuccess(startDate: startDates.first?.value)) { _ in
                            DismissJourney()
                                .sendActionImmediately(ContractStore.self, .fetch)
                                .withCompletedToast
                        }
                        .hidesBackButton.withJourneyDismissButton
                    }
                }
            }
        }
        .withDismissButton
    }
}
