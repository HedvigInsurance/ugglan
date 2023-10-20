import Foundation
import authlib

public enum Environment: Hashable {
    case production
    case staging
    case custom(endpointURL: URL, wsEndpointURL: URL, assetsEndpointURL: URL, webBaseURL: URL)

    fileprivate struct RawCustomStorage: Codable {
        let endpointURL: URL
        let wsEndpointURL: URL
        let assetsEndpointURL: URL
        let webBaseURL: URL
    }

    public var rawValue: String {
        switch self {
        case .production: return "production"
        case .staging: return "staging"
        case let .custom(endpointURL, wsEndpointURL, assetsEndpointURL, webBaseURL):
            let rawCustomStorage = RawCustomStorage(
                endpointURL: endpointURL,
                wsEndpointURL: wsEndpointURL,
                assetsEndpointURL: assetsEndpointURL,
                webBaseURL: webBaseURL
            )
            let data = try? JSONEncoder().encode(rawCustomStorage)

            if let data = data { return String(data: data, encoding: .utf8) ?? "staging" }

            return "staging"
        }
    }

    public var displayName: String {
        switch self {
        case .production: return "production"
        case .staging: return "staging"
        case .custom: return "custom"
        }
    }

    public var datadogName: String {
        switch self {
        case .production: return "prod"
        case .staging: return "dev"
        case .custom: return "custom"
        }
    }

    public init?(
        rawValue: String
    ) {
        switch rawValue {
        case "production": self = .production
        case "staging": self = .staging
        default:
            guard let data = rawValue.data(using: .utf8) else { return nil }

            guard let rawCustomStorage = try? JSONDecoder().decode(RawCustomStorage.self, from: data) else {
                return nil
            }

            self = .custom(
                endpointURL: rawCustomStorage.endpointURL,
                wsEndpointURL: rawCustomStorage.wsEndpointURL,
                assetsEndpointURL: rawCustomStorage.assetsEndpointURL,
                webBaseURL: rawCustomStorage.webBaseURL
            )
        }
    }

    static let targetEnvironmentKey = "targetEnvironment"

    public static var hasOverridenDefault: Bool { UserDefaults.standard.value(forKey: targetEnvironmentKey) != nil }

    public static func setCurrent(_ environment: Environment) {
        UserDefaults.standard.set(environment.rawValue, forKey: targetEnvironmentKey)
    }

    public static var current: Environment {
        guard
            let targetEnvirontmentRawValue = UserDefaults.standard.value(forKey: targetEnvironmentKey)
                as? String, let targetEnvironment = Environment(rawValue: targetEnvirontmentRawValue)
        else {
            if Bundle.main.bundleIdentifier == "com.hedvig.app" { return .production }

            return .staging
        }
        return targetEnvironment
    }

    public var giraffeEndpointURL: URL {
        switch self {
        case .staging: return URL(string: "https://graphql.dev.hedvigit.com/graphql")!
        case .production: return URL(string: "https://giraffe.hedvig.com/graphql")!
        case let .custom(endpointUrl, _, _, _): return endpointUrl
        }
    }

    public var octopusEndpointURL: URL {
        switch self {
        case .staging: return URL(string: "https://apollo-router.dev.hedvigit.com/")!
        case .production: return URL(string: "https://apollo-router.prod.hedvigit.com/")!
        case let .custom(endpointUrl, _, _, _): return endpointUrl
        }
    }

    public var odysseyApiURL: URL {
        switch self {
        case .staging: return URL(string: "https://odyssey.dev.hedvigit.com")!
        case .production: return URL(string: "https://odyssey.prod.hedvigit.com")!
        case .custom: return URL(string: "https://odyssey.dev.hedvigit.com")!
        }
    }

    public var botServiceApiURL: URL {
        switch self {
        case .staging: return URL(string: "https://gateway.dev.hedvigit.com/bot-service/")!
        case .production: return URL(string: "https://gateway.hedvig.com/bot-service/")!
        case .custom: return URL(string: "https://gateway.dev.hedvigit.com/bot-service/")!
        }
    }

    public var giraffeWSEndpointURL: URL {
        switch self {
        case .staging: return URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!
        case .production: return URL(string: "wss://giraffe.hedvig.com/subscriptions")!
        case let .custom(_, wsEndpointURL, _, _): return wsEndpointURL
        }
    }

    public var assetsEndpointURL: URL {
        switch self {
        case .staging: return URL(string: "https://graphql.dev.hedvigit.com")!
        case .production: return URL(string: "https://giraffe.hedvig.com")!
        case let .custom(_, _, assetsUrl, _): return assetsUrl
        }
    }

    public var webBaseURL: URL {
        switch self {
        case .staging: return URL(string: "https://www.dev.hedvigit.com")!
        case .production: return URL(string: "https://www.hedvig.com")!
        case let .custom(_, _, _, webBaseURL): return webBaseURL
        }
    }

    public var deepLinkUrl: String {
        switch self {
        case .staging: return "https://hedvigtest.page.link"
        case .production: return "https://hedvig.page.link"
        case .custom(_, _, _, _): return ""
        }
    }

    public var appStoreURL: URL {
        return URL(string: "https://apps.apple.com/se/app/hedvig/id1303668531")!
    }

    public var authEnvironment: AuthEnvironment {
        switch self {
        case .staging: return .staging
        case .production: return .production
        case .custom(_, _, _, _): return .staging
        }
    }
}
