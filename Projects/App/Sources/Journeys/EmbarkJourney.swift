import Embark
import Foundation
import Offer
import Presentation

extension AppJourney {
    static func embark<OfferResultJourney: JourneyPresentation>(
        _ embark: Embark,
        storeOffer: Bool,
        @JourneyBuilder offerResultJourney: @escaping (_ result: OfferResult) -> OfferResultJourney
    ) -> some JourneyPresentation {
        var offerOptions: Set<OfferOption> = [
            .menuToTrailing
        ]

        if storeOffer {
            offerOptions.insert(.shouldPreserveState)
        }

        return Journey(embark) { externalRedirect in
            switch externalRedirect {
            case .mailingList:
                ContinueJourney()
            case .chat:
                Journey(FreeTextChat(), style: .detented(.large)).withDismissButton
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
                                    storeOffer
                            ),
                        menu: embark.menu,
                        options: offerOptions
                    )
                ) { offerResult in
                    offerResultJourney(offerResult)
                }
                .onDismiss {
                    embark.goBack()
                }
            case let .menu(action):
                action.journey
            }
        }
    }
}
