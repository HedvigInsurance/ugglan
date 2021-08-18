import Foundation

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

  public var endpointURL: URL {
    switch self {
    case .staging: return URL(string: "https://graphql.dev.hedvigit.com/graphql")!
    case .production: return URL(string: "https://giraffe.hedvig.com/graphql")!
    case let .custom(endpointUrl, _, _, _): return endpointUrl
    }
  }

  public var wsEndpointURL: URL {
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
}
