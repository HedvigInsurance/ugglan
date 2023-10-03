import Embark
import Foundation
import Offer
import Presentation

extension AppJourney {
    static func embark<OfferResultJourney: JourneyPresentation>(
        _ embark: Embark,
        storeOffer: Bool,
        style: PresentationStyle = .default,
        @JourneyBuilder offerResultJourney: @escaping (_ result: OfferResult) -> OfferResultJourney
    ) -> some JourneyPresentation {
        var offerOptions: Set<OfferOption> = [
            .menuToTrailing
        ]

        if storeOffer {
            offerOptions.insert(.shouldPreserveState)
        }

        return Journey(embark, style: style) { externalRedirect in
            switch externalRedirect {
            case .mailingList:
                ContinueJourney()
            case .chat:
                AppJourney
                    .freeTextChat()
                    .onDismiss {
                        embark.goBack()
                    }
                    .withDismissButton
            case .close:
                DismissJourney()
            case let .menu(action):
                action.journey
            }
        }
    }
}
