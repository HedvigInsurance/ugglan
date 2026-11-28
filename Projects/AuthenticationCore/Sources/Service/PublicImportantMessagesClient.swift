import Foundation

@MainActor
public protocol PublicImportantMessagesClient {
    /// The active messages, most severe first, in the app's language.
    func getMessages() async throws -> [PublicImportantMessage]
}

public struct PublicImportantMessage: Equatable, Sendable, Identifiable {
    public let id: String
    public let message: String
    public let severity: Severity
    public let link: Link?

    public init(id: String, message: String, severity: Severity, link: Link?) {
        self.id = id
        self.message = message
        self.severity = severity
        self.link = link
    }

    public enum Severity: Sendable {
        case info
        case warning
        case error
    }

    public struct Link: Equatable, Sendable {
        public let url: URL
        public let text: String

        public init(url: URL, text: String) {
            self.url = url
            self.text = text
        }
    }
}
