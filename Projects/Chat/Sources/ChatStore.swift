import Foundation
import Presentation
import hCore

public struct ChatState: StateProtocol {
    public init() {}
    @Transient(defaultValue: false) var askedForPushNotificationsPermission: Bool
}

public enum ChatAction: ActionProtocol {
    case setLastMessageDate(date: Date)
    case checkPushNotificationStatus
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
        default:
            break
        }
        return newState
    }
}
