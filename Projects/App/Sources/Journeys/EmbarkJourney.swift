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
                AppJourney.freeTextChat()
            case .close:
                DismissJourney()
            case let .offer(allIds, selectedIds):
                Journey(
                    Offer(
                        menu: embark.menu,
                        options: offerOptions
                    )
                    .setIds(allIds, selectedIds: selectedIds)
                ) { offerResult in
                    offerResultJourney(offerResult)
                }
                .onDismiss {
                    embark.goBack()
                }
            case let .dataCollection(providerID, providerDisplayName, onComplete):
                DataCollection.journey(providerID: providerID, providerDisplayName: providerDisplayName) { id in
                    onComplete(id)
                }
                .mapJourneyDismissToCancel
            case let .menu(action):
                action.journey
            }
        }
    }
}
