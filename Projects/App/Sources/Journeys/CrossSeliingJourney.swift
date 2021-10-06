import Contracts
import Embark
import Foundation
import Presentation
import hGraphQL

extension AppJourney {
    static func crossSellingJourney(crossSell: CrossSell) -> some JourneyPresentation {
        CrossSellingDetail(crossSell: crossSell).journey { result in
            switch result {
            case let .embark(name):
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
            case .chat:
                ContinueJourney()
            }
        }
    }
}
