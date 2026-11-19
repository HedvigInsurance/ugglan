import AutomaticLog
import hCore

@MainActor
public class MessagesService {
    @Inject var client: MessagesClient

    public init() {}

    @Log
    public func getMessages() async throws -> [InboxMessage] {
        try await client.getMessages()
    }

    @Log
    public func getMessageContent(messageId: String) async throws -> InboxMessageContent {
        try await client.getMessageContent(messageId: messageId)
    }
}
