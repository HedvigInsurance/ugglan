import Foundation
import Market
import Presentation
import hCore

extension AppJourney {
    static var notLoggedIn: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: NotLoggedInView {
                Launch.shared.completeAnimationCallbacker.callAll()
            },
            options: []
        ) { action in
            if case .onboard = action {
                AppJourney.onboarding()
            } else if case .loginButtonTapped = action {
                AppJourney.login
            } else if case .presentMarketPicker = action {
                LanguageAndMarketPickerView().journey { result in
                    ContinueJourney()
                }
                .configureTitle("Preferences")
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
