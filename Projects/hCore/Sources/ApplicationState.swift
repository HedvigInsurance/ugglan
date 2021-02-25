import Foundation
import hGraphQL

public struct ApplicationState {
    public enum Screen: String {
        case onboardingChat, offer, loggedIn, languagePicker, marketPicker, onboarding, webOnboarding, webOffer

        @available(*, deprecated, message: "use marketPicker instead")
        case marketing

        public func isOneOf(_ possibilities: Set<Self>) -> Bool {
            possibilities.contains(self)
        }
    }

    private static let key = "applicationState"

    public static func preserveState(_ screen: Screen) {
        UserDefaults.standard.set(screen.rawValue, forKey: key)
    }

    public static var currentState: Screen? {
        guard
            let applicationStateRawValue = UserDefaults.standard.value(forKey: key) as? String,
            let applicationState = Screen(rawValue: applicationStateRawValue)
        else {
            return nil
        }
        return applicationState
    }

    private static let preferredLocaleKey = "preferredLocale"

    public static func setPreferredLocale(_ locale: Localization.Locale) {
        UserDefaults.standard.set(locale.lprojCode, forKey: "AppleLanguage")
        UserDefaults.standard.set(locale.rawValue, forKey: ApplicationState.preferredLocaleKey)
    }
    
    public static var hasPreferredLocale: Bool {
        UserDefaults.standard.value(forKey: preferredLocaleKey) as? String != nil
    }

    public static var preferredLocale: Localization.Locale {
        guard
            let preferredLocaleRawValue = UserDefaults.standard.value(forKey: preferredLocaleKey) as? String,
            let preferredLocale = Localization.Locale(rawValue: preferredLocaleRawValue)
        else {
            let availableLanguages = Localization.Locale.allCases.map { $0.rawValue }

            let bestMatchedLanguage = Bundle.preferredLocalizations(
                from: availableLanguages
            ).first

            if let bestMatchedLanguage = bestMatchedLanguage {
                return Localization.Locale(rawValue: bestMatchedLanguage) ?? .en_SE
            }
            return .en_SE
        }

        return preferredLocale
    }
}
