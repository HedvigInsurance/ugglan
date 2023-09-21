import Contracts
import Embark
import Foundation
import Presentation
import hCoreUI
import hGraphQL

extension AppJourney {
    static func crossSellingJourney(crossSell: CrossSell) -> some JourneyPresentation {
        CrossSellingDetail(crossSell: crossSell)
            .journey { result in
                switch result {
                case .chat:
                    AppJourney.freeTextChat().withDismissButton
                case let .web(url):
                    AppJourney.webRedirect(url: url)
                }
            }
    }
}
