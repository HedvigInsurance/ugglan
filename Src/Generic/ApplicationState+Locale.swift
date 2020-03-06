//
//  ApplicationState+Locale.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-05.
//

import Foundation
import Common

extension ApplicationState {
    private static let preferredLocaleKey = "preferredLocale"

    static func setPreferredLocale(_ locale: Localization.Locale) {
        UserDefaults.standard.set(locale.rawValue, forKey: ApplicationState.preferredLocaleKey)
    }

    static var hasPreferredLocale: Bool {
        return UserDefaults.standard.value(forKey: preferredLocaleKey) as? String != nil
    }

    static var preferredLocale: Localization.Locale {
        guard
            let preferredLocaleRawValue = UserDefaults.standard.value(forKey: preferredLocaleKey) as? String,
            let preferredLocale = Localization.Locale(rawValue: preferredLocaleRawValue) else {
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
