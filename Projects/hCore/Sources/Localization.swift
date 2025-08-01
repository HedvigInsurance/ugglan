@preconcurrency import Combine
import Foundation
import hGraphQL

@MainActor
public enum Localization {
    @MainActor
    public enum Locale: String, CaseIterable, Hashable {
        public nonisolated(unsafe) static var currentLocale = CurrentValueSubject<Locale, Never>(.sv_SE)
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

        public var accessibilityLanguageCode: String {
            switch self {
            case .sv_SE: return "sv"
            case .en_SE: return "en-US"
            }
        }

        public var displayName: String {
            switch self {
            case .sv_SE: return "Svenska"
            case .en_SE: return "English"
            }
        }

        public nonisolated var foundation: Foundation.Locale { Foundation.Locale(identifier: lprojCode) }

        public nonisolated var lprojCode: String {
            switch self {
            case .sv_SE: return "sv-SE"
            case .en_SE: return "en-SE"
            }
        }

        public nonisolated var translationLocale: Foundation.Locale {
            switch self {
            case .sv_SE: return Foundation.Locale(identifier: "sv-SE")
            case .en_SE: return Foundation.Locale(identifier: "en")
            }
        }

        public nonisolated var translationlprojCode: String {
            switch self {
            case .sv_SE: return "sv-SE"
            case .en_SE: return "en"
            }
        }
    }
}
