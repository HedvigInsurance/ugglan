import Combine
import Foundation
import hGraphQL

public enum Localization {
    public enum Locale: String, CaseIterable, Hashable {
        //        public static var currentLocale: Locale = .sv_SE
        public static var currentLocale = CurrentValueSubject<Locale, Never>(.sv_SE)
        case sv_SE
        case en_SE

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
