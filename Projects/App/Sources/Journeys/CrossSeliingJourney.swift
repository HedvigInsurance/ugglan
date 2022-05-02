import Contracts
import Embark
import Foundation
import Presentation
import hGraphQL
import hCoreUI

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
            case let .openCheckout(token):
                AppJourney.offerCheckout(with: token)
            case .signedQuoteCart:
                DismissJourney()
            case let .openPerilDetail(peril):
                Journey(
                    PerilDetail(peril: peril),
                    style: .detented(.preferredContentSize, .large)
                )
                .withDismissButton
            }
        }
    }

    static func crossSellingJourney(crossSell: CrossSell) -> some JourneyPresentation {
        CrossSellingDetail(crossSell: crossSell)
            .journey { result in
                switch result {
                case let .embark(name):
                    AppJourney.crossSellingEmbarkJourney(name: name, style: .default)
                case .chat:
                    AppJourney.freeTextChat().withDismissButton
                }
            }
    }
}
