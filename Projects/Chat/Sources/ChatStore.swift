import Foundation
import StoreContainer
import hCore

public struct ChatState: StateProtocol {
    public init() {}
    @Transient(defaultValue: false) var askedForPushNotificationsPermission: Bool
    public var conversationsTimeStamp = [String: Date]()
    public var messagesTimeStamp = Date()
}

public enum ChatAction: ActionProtocol {
    case setLastMessageDate(date: Date)
    case setLastMessageTimestampForConversation(id: String, date: Date)
    case checkPushNotificationStatus
}

final public class ChatStore: StateStore<ChatState, ChatAction> {

    public func hasNotification(conversationId: String, timeStamp: Date?) -> Bool {
        if let stateTimeStamp = state.conversationsTimeStamp[conversationId] {
            return stateTimeStamp < timeStamp ?? Date()
        }
        send(.setLastMessageTimestampForConversation(id: conversationId, date: Date()))
        return false
    }

    public override func effects(
        _ getState: @escaping () -> ChatState,
        _ action: ChatAction
    ) async {}

    public override func reduce(_ state: ChatState, _ action: ChatAction) -> ChatState {
        var newState = state
        switch action {
        case .checkPushNotificationStatus:
            newState.askedForPushNotificationsPermission = true
        case let .setLastMessageTimestampForConversation(id, date):
            newState.conversationsTimeStamp[id] = date
        case let .setLastMessageDate(date):
            newState.messagesTimeStamp = date
        }
        return newState
    }
}
