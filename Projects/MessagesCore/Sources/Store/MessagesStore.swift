import AppStateContainer
import Foundation
import Observation
import hCore

/// Shared because the Home bell badge and the Messages screens both read the unread state.
@MainActor
@PersistableStore
@Observable
public final class MessagesStore: AppStore {
    private let service = MessagesService()

    /// Not persisted: email content is always fetched fresh.
    @Transient public private(set) var state: LoadState<[InboxMessage]> = .notLoaded

    public var messages: [InboxMessage] { state.value ?? [] }

    public var unreadCount: Int { messages.filter { !$0.isRead }.count }

    public init() {}

    public func fetchMessages() async {
        // Keep the current list on screen while refreshing; only show the loader on the first load.
        if state.value == nil {
            state = .loading
        }
        do {
            state = .loaded(try await service.getMessages())
        } catch {
            if state.value == nil {
                state = .failed(errorMessage: error.localizedDescription)
            }
        }
    }

    public func message(with id: String) -> InboxMessage? {
        messages.first { $0.id == id }
    }

    /// Optimistic: the message reads as opened at once, and goes back to unread if the request fails.
    public func markAsRead(messageId: String) async {
        guard let message = message(with: messageId), !message.isRead else { return }
        setIsRead(true, for: messageId)
        do {
            try await service.markAsRead(messageId: messageId)
        } catch {
            setIsRead(false, for: messageId)
        }
    }

    private func setIsRead(_ isRead: Bool, for messageId: String) {
        guard var messages = state.value, let index = messages.firstIndex(where: { $0.id == messageId }) else {
            return
        }
        messages[index].isRead = isRead
        state = .loaded(messages)
    }
}
