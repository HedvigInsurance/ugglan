import Foundation
import hGraphQL

public struct ApplicationState {
	public enum Screen: String {
		case onboardingChat, offer, loggedIn, languagePicker, marketPicker, onboarding

		@available(*, deprecated, message: "use marketPicker instead") case marketing

		public func isOneOf(_ possibilities: Set<Self>) -> Bool { possibilities.contains(self) }
	}

	private static let key = "applicationState"

	public static func preserveState(_ screen: Screen) { UserDefaults.standard.set(screen.rawValue, forKey: key) }

	public static var currentState: Screen? {
		guard let applicationStateRawValue = UserDefaults.standard.value(forKey: key) as? String,
			let applicationState = Screen(rawValue: applicationStateRawValue)
		else { return nil }
		return applicationState
	}

	private static let preferredLocaleKey = "preferredLocale"
	private static let marketKey = "market"

	public static func setPreferredLocale(_ locale: Localization.Locale) {
		UserDefaults.standard.setValue([locale.lprojCode], forKey: "AppleLanguages")
		UserDefaults.standard.synchronize()
		setMarket(locale.market)
	}

	public static func setMarket(_ market: Localization.Locale.Market) {
		UserDefaults.standard.set(market.rawValue, forKey: ApplicationState.marketKey)
	}

	public static func getMarket() -> Localization.Locale.Market? {
		if let marketRawValue = UserDefaults.standard.value(forKey: marketKey) as? String,
			let market = Localization.Locale.Market(rawValue: marketRawValue)
		{
			return market
		}

		return nil
	}

	private static var hasPreferredLocale: Bool {
		UserDefaults.standard.value(forKey: preferredLocaleKey) as? String != nil
	}

	public static var preferredLocale: Localization.Locale {
		if hasPreferredLocale {
			if let preferredLocaleRawValue = UserDefaults.standard.value(forKey: preferredLocaleKey)
				as? String, let preferredLocale = Localization.Locale(rawValue: preferredLocaleRawValue)
			{
				setPreferredLocale(preferredLocale)
				UserDefaults.standard.removeObject(forKey: preferredLocaleKey)
				UserDefaults.standard.synchronize()
				return preferredLocale
			}
		}

		func preferredLocaleForMarket(_ market: Localization.Locale.Market) -> Localization.Locale? {
			let availableLanguages = market.availableLocales.map { $0.lprojCode }

			let bestMatchedLanguage = Bundle.preferredLocalizations(from: availableLanguages).first

			if let bestMatchedLanguage = bestMatchedLanguage {
				return Localization.Locale(
					rawValue: bestMatchedLanguage.replacingOccurrences(of: "-", with: "_")
				)
			}

			return nil
		}

		if let market = getMarket(), let locale = preferredLocaleForMarket(market) { return locale }

		let availableLanguages = Localization.Locale.allCases.map { $0.lprojCode }

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
