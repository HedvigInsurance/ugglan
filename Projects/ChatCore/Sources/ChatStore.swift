import AppStateContainer
import Foundation
import Observation
import hCore

public typealias ConversationId = String

@MainActor
@PersistableStore
@Observable
public final class ChatStore: AppStore {
    public internal(set) var failedMessages: [ConversationId: [Message]] = [:]

    @Transient
    public internal(set) var askedForPushNotificationsPermission: Bool = false

    public init() {}

    public func checkPushNotificationStatus() {
        askedForPushNotificationsPermission = true
    }

    public func setFailedMessage(conversationId: ConversationId, message: Message) {
        var messages = failedMessages[conversationId] ?? []
        messages.append(message)
        failedMessages[conversationId] = messages
    }

    public func clearFailedMessage(conversationId: ConversationId, message: Message) {
        if let index = failedMessages[conversationId]?.firstIndex(where: { $0.id == message.id }) {
            failedMessages[conversationId]?.remove(at: index)
        }
    }
}
