import Foundation
import hGraphQL

public enum Localization {
	public enum Locale: String, CaseIterable, Hashable {
		@ReadWriteState public static var currentLocale: Locale = .sv_SE
		case sv_SE
		case en_SE
		case en_NO
		case nb_NO
		case da_DK
		case en_DK

		public enum Market: String {
			case no = "NO"
			case se = "SE"
			case dk = "DK"

			public var currencyCode: String {
				switch self {
				case .no: return "NOK"
				case .dk: return "DKK"
				case .se: return "SEK"
				}
			}

			public var availableLocales: [Localization.Locale] {
				switch self {
				case .no: return [.nb_NO, .en_NO]
				case .dk: return [.da_DK, .en_DK]
				case .se: return [.sv_SE, .en_SE]
				}
			}

			public var marketName: String {
				switch self {
				case .no: return L10n.marketNorway
				case .se: return L10n.marketSweden
				case .dk: return L10n.marketDenmark
				}
			}
		}

		public var market: Market {
			switch self {
			case .sv_SE, .en_SE: return .se
			case .en_NO, .nb_NO: return .no
			case .da_DK, .en_DK: return .dk
			}
		}

		public var embark: Locale { .en_NO }

		public var acceptLanguageHeader: String {
			switch self {
			case .sv_SE: return "sv-SE"
			case .en_SE: return "en-SE"
			case .en_NO: return "en-NO"
			case .nb_NO: return "nb-NO"
			case .da_DK: return "da-DK"
			case .en_DK: return "en-DK"
			}
		}

		public var webPath: String {
			switch self {
			case .sv_SE: return "se"
			case .en_SE: return "se-en"
			case .en_NO: return "no-en"
			case .nb_NO: return "no"
			case .da_DK: return "dk"
			case .en_DK: return "dk-en"
			}
		}

		public var code: String {
			switch self {
			case .sv_SE: return "sv_SE"
			case .en_SE: return "en_SE"
			case .en_NO: return "en_NO"
			case .nb_NO: return "nb_NO"
			case .da_DK: return "da_DK"
			case .en_DK: return "en_DK"
			}
		}

		public var displayName: String {
			switch self {
			case .sv_SE: return "Svenska"
			case .en_SE: return "English"
			case .en_NO: return "English"
			case .nb_NO: return "Norsk (Bokmål)"
			case .da_DK: return "Dansk"
			case .en_DK: return "English"
			}
		}

		public var foundation: Foundation.Locale { Foundation.Locale(identifier: lprojCode) }

		public var lprojCode: String {
			switch self {
			case .sv_SE: return "sv-SE"
			case .en_SE: return "en-SE"
			case .en_NO: return "en-NO"
			case .nb_NO: return "nb-NO"
			case .da_DK: return "da-DK"
			case .en_DK: return "en-DK"
			}
		}
	}
}

extension Localization.Locale {
	public func asGraphQLLocale() -> hGraphQL.GraphQL.Locale {
		switch self {
		case .sv_SE: return .svSe
		case .en_SE: return .enSe
		case .nb_NO: return .nbNo
		case .en_NO: return .enNo
		case .da_DK: return .daDk
		case .en_DK: return .enDk
		}
	}
}
