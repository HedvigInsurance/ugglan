import SwiftUI

public enum PowerOfAttorneyLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case full = "Full"
    case partial = "CoInsured"

    /// A level this app version doesn't know is treated as the most limited one.
    public init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = PowerOfAttorneyLevel(rawValue: rawValue) ?? .partial
    }
}

public struct ActingPowerOfAttorney: Codable, Equatable, Sendable {
    /// Personal number of the person using the power of attorney
    public let ssn: String
    /// Name of the person using the power of attorney
    public let name: String
    public let level: PowerOfAttorneyLevel

    public init(ssn: String, name: String, level: PowerOfAttorneyLevel) {
        self.ssn = ssn
        self.name = name
        self.level = level
    }

    public var hasFullAccess: Bool { level == .full }

    /// The first word of `name`, used for greeting.
    public var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    /// Deep links a limited power of attorney may open: home, the inbox, claims and the insurances.
    public func allows(_ deepLink: DeepLink) -> Bool {
        guard !hasFullAccess else { return true }
        switch deepLink {
        case .home, .chat, .inbox, .conversation, .claimDetails, .submitClaim, .claimChat, .insurances, .contract:
            return true
        default:
            return false
        }
    }
}

extension EnvironmentValues {
    /// Set when someone uses the app with a power of attorney, `nil` for the member themselves.
    @Entry public var actingPowerOfAttorney: ActingPowerOfAttorney? = nil

    /// Whether the app is limited to what a power of attorney without full access may see and do.
    public var hasLimitedAccess: Bool {
        actingPowerOfAttorney.map { !$0.hasFullAccess } ?? false
    }
}
