import AppStateContainer
import Foundation
import Observation
import hCore

/// Shared because Home loads the inbox and the Messages screens read it.
@MainActor
@PersistableStore
@Observable
public final class MessagesStore: AppStore {
    private let service = MessagesService()

    /// Not persisted: email content is always fetched fresh.
    @Transient public private(set) var state: LoadState<[InboxMessage]> = .notLoaded

    public var messages: [InboxMessage] { state.value ?? [] }

    public init() {}

    public func fetchMessages() async {
        // Keep the current list on screen while refreshing; only show the loader on the first load.
        if state.value == nil {
            state = .loading
        }
        do {
            let fetched = try await service.getMessages()
            // Bodies aren't part of the list; keep the ones already loaded so reopening a message is instant.
            let loadedBodies = messages.reduce(into: [String: String]()) { $0[$1.id] = $1.body }
            state = .loaded(
                fetched.map { message in
                    var message = message
                    message.body = message.body ?? loadedBodies[message.id]
                    return message
                }
            )
        } catch {
            if state.value == nil {
                state = .failed(errorMessage: error.localizedDescription)
            }
        }
    }

    public func message(with id: String) -> InboxMessage? {
        messages.first { $0.id == id }
    }

    /// Fetches the body of a message once and keeps it on the message, along with its preheader if the list had none.
    public func loadBody(messageId: String) async throws {
        guard let message = message(with: messageId), message.body == nil else { return }
        let content = try await service.getMessageContent(messageId: messageId)
        guard var messages = state.value, let index = messages.firstIndex(where: { $0.id == messageId }) else {
            return
        }
        messages[index].body = content.body
        messages[index].preview = messages[index].preview ?? content.preview
        state = .loaded(messages)
    }
}
