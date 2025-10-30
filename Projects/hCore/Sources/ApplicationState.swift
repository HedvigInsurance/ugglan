import Foundation
import SwiftUI

@MainActor
public struct ApplicationState {
    @AppStorage(key) public static var state: ApplicationState.Screen = .notLoggedIn
    public enum Screen: String {
        case onboardingChat, offer, loggedIn, languagePicker, notLoggedIn, onboarding, impersonation

        @available(*, deprecated, message: "use marketPicker instead") case marketing

        public func isOneOf(_ possibilities: Set<Self>) -> Bool { possibilities.contains(self) }
    }

    public static let key = "applicationState"

    public static func preserveState(_ screen: Screen) { UserDefaults.standard.set(screen.rawValue, forKey: key) }

    public static var currentState: Screen? {
        guard let applicationStateRawValue = UserDefaults.standard.value(forKey: key) as? String,
            let applicationState = Screen(rawValue: applicationStateRawValue)
        else { return nil }
        return applicationState
    }

    private static let preferredLocaleKey = "preferredLocale"

    public static func setPreferredLocale(_ locale: Localization.Locale) {
        UserDefaults.standard.setValue([locale.lprojCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    private static var hasPreferredLocale: Bool {
        UserDefaults.standard.value(forKey: preferredLocaleKey) as? String != nil
    }

    public static var preferredLocale: Localization.Locale {
        if hasPreferredLocale {
            if let preferredLocaleRawValue = UserDefaults.standard.value(forKey: preferredLocaleKey)
                as? String, let preferredLocale = Localization.Locale(rawValue: preferredLocaleRawValue)
            {
                ApplicationState.setPreferredLocale(preferredLocale)
                UserDefaults.standard.removeObject(forKey: preferredLocaleKey)
                UserDefaults.standard.synchronize()
                return preferredLocale
            }
        }
        let availableLanguages = Localization.Locale.allCases.map(\.lprojCode)

        let bestMatchedLanguage = Bundle.preferredLocalizations(from: availableLanguages).first

        if let bestMatchedLanguage = bestMatchedLanguage,
            let locale = Localization.Locale(
                rawValue: bestMatchedLanguage.replacingOccurrences(of: "-", with: "_")
            )
        {
            return locale
        }

        return .en_SE
    }
}
