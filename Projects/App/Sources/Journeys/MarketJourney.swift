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
            if case .onboard = action {
                AppJourney.onboarding()
            } else if case .loginButtonTapped = action {
                AppJourney.login
            } else if case let .presentMarketPicker(currentMarket) = action {
                PickMarket(currentMarket: currentMarket).journey
            } else if case let .presentLanguagePicker(currentMarket) = action {
                PickLanguage(currentMarket: currentMarket).journey
            }
        }
    }
}
