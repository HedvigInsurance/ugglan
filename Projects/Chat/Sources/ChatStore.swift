import Foundation
import PresentableStore
import hCore

public struct ChatState: StateProtocol {
    public init() {}

    @Transient(defaultValue: false) var askedForPushNotificationsPermission: Bool
    public var failedMessages: [Message] = []
}

public enum ChatAction: ActionProtocol {
    case checkPushNotificationStatus
    case setFailedMessage(Message)
    case clearFailedMessage(Message)
}

final public class ChatStore: StateStore<ChatState, ChatAction> {

    public override func effects(
        _ getState: @escaping () -> ChatState,
        _ action: ChatAction
    ) async {}

    public override func reduce(_ state: ChatState, _ action: ChatAction) -> ChatState {
        var newState = state
        switch action {
        case .checkPushNotificationStatus:
            newState.askedForPushNotificationsPermission = true
        case let .setFailedMessage(message):
            var failedMessages = state.failedMessages
            failedMessages.append(message)
            newState.failedMessages = failedMessages
        case let .clearFailedMessage(message):
            var failedMessages = state.failedMessages
            if let index = failedMessages.firstIndex(where: { $0.id == message.id }) {
                failedMessages.remove(at: index)
            }
            newState.failedMessages = failedMessages
        }
        return newState
    }
}
