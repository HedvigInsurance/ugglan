import Foundation
import hGraphQL

public enum Localization {
    public enum Locale: String, CaseIterable, Hashable {
        @ReadWriteState public static var currentLocale: Locale = .sv_SE
        case sv_SE
        case en_SE

        public enum Market: String, Codable, CaseIterable {
            case se = "SE"

            public var currencyCode: String {
                switch self {
                case .se: return "SEK"
                }
            }

            public var availableLocales: [Localization.Locale] {
                switch self {
                case .se: return [.sv_SE, .en_SE]
                }
            }

            public var marketName: String {
                switch self {
                case .se: return L10n.marketSweden
                }
            }
        }

        public var market: Market {
            switch self {
            case .sv_SE, .en_SE: return .se
            }
        }

        public var acceptLanguageHeader: String {
            switch self {
            case .sv_SE: return "sv-SE"
            case .en_SE: return "en-SE"
            }
        }

        public var webPath: String {
            switch self {
            case .sv_SE: return "se"
            case .en_SE: return "se-en"
            }
        }

        public var priceQoutePath: String {
            switch self {
            case .sv_SE: return "forsakringar"
            case .en_SE: return "insurances"
            }
        }

        public var code: String {
            switch self {
            case .sv_SE: return "sv_SE"
            case .en_SE: return "en_SE"
            }
        }

        public var displayName: String {
            switch self {
            case .sv_SE: return "Svenska"
            case .en_SE: return "English"
            }
        }

        public var foundation: Foundation.Locale { Foundation.Locale(identifier: lprojCode) }

        public var lprojCode: String {
            switch self {
            case .sv_SE: return "sv-SE"
            case .en_SE: return "en-SE"
            }
        }
    }
}
