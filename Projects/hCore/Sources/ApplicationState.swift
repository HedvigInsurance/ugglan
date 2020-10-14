import Foundation

public struct ApplicationState {
    public enum Screen: String {
        case onboardingChat, offer, loggedIn, languagePicker, marketPicker, onboarding

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
            let applicationState = Screen(rawValue: applicationStateRawValue) else {
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

    public static let targetEnvironmentKey = "targetEnvironment"

    public enum Environment: Hashable {
        case production
        case staging
        case custom(endpointURL: URL, wsEndpointURL: URL, assetsEndpointURL: URL)

        fileprivate struct RawCustomStorage: Codable {
            let endpointURL: URL
            let wsEndpointURL: URL
            let assetsEndpointURL: URL
        }

        public var rawValue: String {
            switch self {
            case .production:
                return "production"
            case .staging:
                return "staging"
            case let .custom(endpointURL, wsEndpointURL, assetsEndpointURL):
                let rawCustomStorage = RawCustomStorage(
                    endpointURL: endpointURL,
                    wsEndpointURL: wsEndpointURL,
                    assetsEndpointURL: assetsEndpointURL
                )
                let data = try? JSONEncoder().encode(rawCustomStorage)

                if let data = data {
                    return String(data: data, encoding: .utf8) ?? "staging"
                }

                return "staging"
            }
        }

        public var displayName: String {
            switch self {
            case .production:
                return "production"
            case .staging:
                return "staging"
            case .custom:
                return "custom"
            }
        }

        public init?(rawValue: String) {
            switch rawValue {
            case "production":
                self = .production
            case "staging":
                self = .staging
            default:
                guard let data = rawValue.data(using: .utf8) else {
                    return nil
                }

                guard let rawCustomStorage = try? JSONDecoder().decode(RawCustomStorage.self, from: data) else {
                    return nil
                }

                self = .custom(
                    endpointURL: rawCustomStorage.endpointURL,
                    wsEndpointURL: rawCustomStorage.wsEndpointURL,
                    assetsEndpointURL: rawCustomStorage.assetsEndpointURL
                )
            }
        }
    }

    public static func setTargetEnvironment(_ environment: Environment) {
        UserDefaults.standard.set(environment.rawValue, forKey: targetEnvironmentKey)
    }

    public static func getTargetEnvironment() -> Environment {
        guard
            let targetEnvirontmentRawValue = UserDefaults.standard.value(forKey: targetEnvironmentKey) as? String,
            let targetEnvironment = Environment(rawValue: targetEnvirontmentRawValue) else {
            if Bundle.main.bundleIdentifier == "com.hedvig.app" {
                return .production
            }

            return .staging
        }
        return targetEnvironment
    }

    public static var hasOverridenTargetEnvironment: Bool {
        UserDefaults.standard.value(forKey: targetEnvironmentKey) != nil
    }
}
