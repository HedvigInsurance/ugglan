import Foundation
import MessagesCore
import hCore

/// There is no Octopus API for the messages inbox yet, so this serves the demo inbox. The feature is only
/// reachable behind the `enable_messages_inbox` flag. Replace with the real queries once the API exists.
@MainActor
class MessagesClientOctopus: MessagesClient {
    private let demoClient = MessagesClientDemo()

    func getMessages() async throws -> [InboxMessage] {
        try await demoClient.getMessages()
    }

    func markAsRead(messageId: String) async throws {
        try await demoClient.markAsRead(messageId: messageId)
    }
}
