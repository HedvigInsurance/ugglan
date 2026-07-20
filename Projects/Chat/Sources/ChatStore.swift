import AppStateContainer
import Foundation
import hCore

public typealias ConversationId = String

@MainActor
@PersistableStore
public final class ChatStore: AppStore {
    @Published public internal(set) var failedMessages: [ConversationId: [Message]] = [:]

    @Transient
    @Published public internal(set) var askedForPushNotificationsPermission: Bool = false

    public init() {}

    func checkPushNotificationStatus() {
        askedForPushNotificationsPermission = true
    }

    func setFailedMessage(conversationId: ConversationId, message: Message) {
        var messages = failedMessages[conversationId] ?? []
        messages.append(message)
        failedMessages[conversationId] = messages
    }

    func clearFailedMessage(conversationId: ConversationId, message: Message) {
        if let index = failedMessages[conversationId]?.firstIndex(where: { $0.id == message.id }) {
            failedMessages[conversationId]?.remove(at: index)
        }
    }
}
