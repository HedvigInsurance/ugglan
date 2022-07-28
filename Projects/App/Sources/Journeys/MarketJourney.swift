import Foundation
import Market
import Presentation
import hCore

extension AppJourney {
    static var marketPicker: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: MarketPickerView()
        ) { action in
            if case .openMarketing = action {
                Journey(
                    Marketing(),
                    options: [.replaceDetail]
                ) { marketingResult in
                    switch marketingResult {
                    case .onboard:
                        AppJourney.onboarding()
                    case .login:
                        AppJourney.login
                    }
                }
            } else if case let .presentMarketPicker(currentMarket) = action {
                PickMarket(currentMarket: currentMarket).journey
            } else if case let .presentLanguagePicker(currentMarket) = action {
                PickLanguage(currentMarket: currentMarket).journey
            }
        }
    }
}
