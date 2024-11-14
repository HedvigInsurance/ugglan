import Foundation
import PresentableStore
import hCore

public typealias ConverastionId = String
public struct ChatState: StateProtocol {
    public init() {}

    @Transient(defaultValue: false) var askedForPushNotificationsPermission: Bool
    public var failedMessages: [ConverastionId: [Message]] = [:]
}

public enum ChatAction: ActionProtocol {
    case checkPushNotificationStatus
    case setFailedMessage(conversationId: String, message: Message)
    case clearFailedMessage(conversationId: String, message: Message)
}

final public class ChatStore: StateStore<ChatState, ChatAction> {

    public override func effects(
        _ getState: @escaping () -> ChatState,
        _ action: ChatAction
    ) async {}

    public override func reduce(_ state: ChatState, _ action: ChatAction) async -> ChatState {
        var newState = state
        switch action {
        case .checkPushNotificationStatus:
            newState.askedForPushNotificationsPermission = true
        case let .setFailedMessage(conversationId, message):
            var failedMessages = state.failedMessages
            var messages = failedMessages[conversationId] ?? []
            messages.append(message)
            failedMessages[conversationId] = messages
            newState.failedMessages = failedMessages
        case let .clearFailedMessage(conversationId, message):
            var failedMessages = state.failedMessages
            if let index = failedMessages[conversationId]?.firstIndex(where: { $0.id == message.id }) {
                failedMessages[conversationId]?.remove(at: index)
            }
            newState.failedMessages = failedMessages
        }
        return newState
    }
}
