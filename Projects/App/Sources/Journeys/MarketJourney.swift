import Foundation
import Market
import Presentation

extension AppJourney {
    static var marketPicker: some JourneyPresentation {
        Journey(MarketPicker()) { _ in
            Journey(Marketing()) { marketingResult in
                switch marketingResult {
                case let .onboard(id):
                    AppJourney.onboarding(cartId: id)
                case .login:
                    AppJourney.login
                }
            }
        }
    }
}
