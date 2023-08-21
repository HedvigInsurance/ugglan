import Foundation
import Market
import Presentation
import hCore

extension AppJourney {
    static var marketPicker: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: MarketPickerView {
                Launch.shared.completeAnimationCallbacker.callAll()
            }
        ) { action in
            if case .onboard = action {
                AppJourney.onboarding()
            } else if case .loginButtonTapped = action {
                AppJourney.login
            } else if case let .presentMarketPicker(currentMarket) = action {
                PickMarket(
                    currentMarket: currentMarket,
                    onSave: { selectedMarket in
                        let store: MarketStore = globalPresentableStoreContainer.get()
                        store.send(.selectMarket(market: selectedMarket))
                    },
                    onCancel: {
                    }
                )
                .journey
            } else if case .presentLanguagePicker = action {
                PickLanguage(
                    onSave: { selectedLocale in
                        Localization.Locale.currentLocale = selectedLocale
                    },
                    onCancel: {}
                )
                .journey
            }
        }
    }
}
