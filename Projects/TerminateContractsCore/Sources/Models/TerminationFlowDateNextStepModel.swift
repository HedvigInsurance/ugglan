import Foundation

public struct ExtraCoverageItem: Codable, Equatable, Hashable, Sendable {
    public let displayName: String
    public let displayValue: String?

    public init(displayName: String, displayValue: String?) {
        self.displayName = displayName
        self.displayValue = displayValue
    }
}

public struct TerminationNotification: Codable, Equatable, Hashable, Sendable {
    public let message: String
    public let type: TerminationNotificationType

    public init(message: String, type: TerminationNotificationType) {
        self.message = message
        self.type = type
    }
}

public enum TerminationNotificationType: String, Codable, Sendable {
    case info
    case warning
}
