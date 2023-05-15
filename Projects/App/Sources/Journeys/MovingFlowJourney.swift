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

    public static var movingFlow: some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: MovingFlowHousingType(),
            style: .detented(.large, modally: false),
            options: [
                .defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.always),
            ]
        ) { action in
            if case .goToFreeTextChat = action {
                AppJourney.freeTextChat(style: .default).withJourneyDismissButton
            }
        }
        //        {
        //            action in
        //            if case let .entrypointGroupSelected(origin) = action {
        //                GroupJourney { context in
        //                    switch origin {
        //                    case .generic:
        //                        ContinueJourney()
        //                    case let .commonClaims(id):
        //                        redirectJourney(ClaimsOrigin.commonClaims(id: id))
        //                    }
        //                }
        //            }
        //        }
    }

    //    @JourneyBuilder
    //    static var movingFlow: some JourneyPresentation {
    //        Journey(
    //            MovingFlowHousingType(),
    //            style: .detented(.large)
    //            )
    //        ) { introRoute in
    //            switch introRoute {
    //            case .chat:
    //                AppJourney.freeTextChat(style: .default).withJourneyDismissButton
    //            case let .embark(name):
    //                AppJourney.embark(Embark(name: name), storeOffer: false) { offerResult in
    //                    switch offerResult {
    //                    case .chat:
    //                        AppJourney.freeTextChat().withDismissButton
    //                    case .close:
    //                        DismissJourney()
    //                    case .menu:
    //                        ContinueJourney()
    //                    case let .signed(_, startDates), let .signedQuoteCart(_, startDates):
    //                        Journey(MovingFlowSuccess(startDate: startDates.first?.value)) { _ in
    //                            DismissJourney()
    //                                .sendActionImmediately(ContractStore.self, .fetch)
    //                                .withCompletedToast
    //                        }
    //                        .hidesBackButton.withJourneyDismissButton
    //                    }
    //                }
    //            }
    //        }
    //        .withDismissButton
    //    }

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
