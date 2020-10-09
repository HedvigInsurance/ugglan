import Foundation
import hGraphQL

public struct Localization {
    public enum Locale: String, CaseIterable {
        @ReadWriteState public static var currentLocale: Locale = .sv_SE
        case sv_SE
        case en_SE
        case en_NO
        case nb_NO

        public enum Market: String {
            case no = "NO"
            case se = "SE"
        }

        public var market: Market {
            switch self {
            case .sv_SE:
                return .se
            case .en_SE:
                return .se
            case .en_NO:
                return .no
            case .nb_NO:
                return .no
            }
        }

        public var acceptLanguageHeader: String {
            switch self {
            case .sv_SE:
                return "sv-SE"
            case .en_SE:
                return "en-SE"
            case .en_NO:
                return "en-NO"
            case .nb_NO:
                return "nb-NO"
            }
        }

        public var code: String {
            switch self {
            case .sv_SE:
                return "sv_SE"
            case .en_SE:
                return "en_SE"
            case .en_NO:
                return "en_NO"
            case .nb_NO:
                return "nb_NO"
            }
        }

        public var displayName: String {
            switch self {
            case .sv_SE:
                return "Svenska"
            case .en_SE:
                return "English"
            case .en_NO:
                return "English"
            case .nb_NO:
                return "Norsk (Bokmål)"
            }
        }

        public var lprojCode: String {
            switch self {
            case .sv_SE:
                return "sv-SE"
            case .en_SE:
                return "en-SE"
            case .en_NO:
                return "en-NO"
            case .nb_NO:
                return "nb-NO"
            }
        }
    }
}

extension Localization.Locale {
    public func asGraphQLLocale() -> hGraphQL.GraphQL.Locale {
        switch self {
        case .sv_SE:
            return .svSe
        case .en_SE:
            return .enSe
        case .nb_NO:
            return .nbNo
        case .en_NO:
            return .enNo
        }
    }
}
