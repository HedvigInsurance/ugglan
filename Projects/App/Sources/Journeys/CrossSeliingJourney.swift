import Contracts
import Embark
import Foundation
import Presentation
import hCoreUI
import hGraphQL

extension AppJourney {
    static func crossSellingEmbarkJourney(name: String, style: PresentationStyle) -> some JourneyPresentation {
        AppJourney.embark(
            Embark(name: name),
            storeOffer: false,
            style: style
        ) { offerResult in
            switch offerResult {
            case .chat:
                AppJourney.freeTextChat().withDismissButton
            case .close:
                DismissJourney()
            case .menu:
                ContinueJourney()
            case let .signed(_, startDates):
                CrossSellingSigned.journey(startDate: startDates.first?.value)
            case .signedQuoteCart:
                DismissJourney()
            }
        }
    }
}
