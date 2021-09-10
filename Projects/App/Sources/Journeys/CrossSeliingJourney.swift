import Contracts
import Embark
import Foundation
import Presentation

extension AppJourney {
    static func crossSellingJourney(name: String) -> some JourneyPresentation {
        AppJourney.embark(
            Embark(name: name),
            storeOffer: false,
            style: .detented(.large)
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
            }
        }
    }
}
