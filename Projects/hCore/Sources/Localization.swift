@preconcurrency import Combine
import Foundation
import hGraphQL

@MainActor
public enum Localization {
    @MainActor
    public enum Locale: String, CaseIterable, Hashable {
        //        public static var currentLocale: Locale = .sv_SE
        nonisolated(unsafe)
            public static var currentLocale = CurrentValueSubject<Locale, Never>(.sv_SE)
        case sv_SE
        case en_SE
        case en_NO
        case en_DK
        @MainActor
        public enum Market: String, Codable, CaseIterable {
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
                case .no: return [.en_NO]
                case .dk: return [.en_DK]
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

        nonisolated
            public var market: Market
        {
            switch self {
            case .sv_SE, .en_SE: return .se
            case .en_NO: return .no
            case .en_DK: return .dk
            }
        }

        public var embark: Locale { .en_NO }

        public var acceptLanguageHeader: String {
            switch self {
            case .sv_SE: return "sv-SE"
            case .en_SE: return "en-SE"
            case .en_NO: return "en-NO"
            case .en_DK: return "en-DK"
            }
        }

        public var webPath: String {
            switch self {
            case .sv_SE: return "se"
            case .en_SE: return "se-en"
            case .en_NO: return "no-en"
            case .en_DK: return "dk-en"
            }
        }

        public var priceQoutePath: String {
            switch self {
            case .sv_SE: return "forsakringar"
            case .en_SE: return "insurances"
            default: return "new-member"
            }
        }

        public var code: String {
            switch self {
            case .sv_SE: return "sv_SE"
            case .en_SE: return "en_SE"
            case .en_NO: return "en_NO"
            case .en_DK: return "en_DK"
            }
        }

        public var accessibilityLanguageCode: String {
            switch self {
            case .sv_SE: return "sv"
            case .en_SE: return "en-US"
            case .en_NO: return "en-US"
            case .en_DK: return "en-US"
            }
        }

        public var displayName: String {
            switch self {
            case .sv_SE: return "Svenska"
            case .en_SE: return "English"
            case .en_NO: return "English"
            case .en_DK: return "English"
            }
        }

        nonisolated
            public var foundation: Foundation.Locale
        { Foundation.Locale(identifier: lprojCode) }

        nonisolated
            public var lprojCode: String
        {
            switch self {
            case .sv_SE: return "sv-SE"
            case .en_SE: return "en-SE"
            case .en_NO: return "en-NO"
            case .en_DK: return "en-DK"
            }
        }
    }
}
