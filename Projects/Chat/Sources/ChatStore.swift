import Flow
import Foundation
import Presentation
import hCore

public struct ChatState: StateProtocol {
    public init() {}
    @Transient(defaultValue: false) var askedForPushNotificationsPermission: Bool
    @Transient(defaultValue: true) public var allowNewMessageToast: Bool
}

public enum ChatAction: ActionProtocol {
    case setAllowNewMessages(allow: Bool)
    case setLastMessageDate(date: Date)
    case checkPushNotificationStatus
    case navigation(action: ChatNavigationAction)
}

public enum ChatNavigationAction: ActionProtocol {
    case redirectAction
    case linkClicked(url: URL)
    case closeChat
}

final public class ChatStore: StateStore<ChatState, ChatAction> {
    public override func effects(
        _ getState: @escaping () -> ChatState,
        _ action: ChatAction
    ) -> FiniteSignal<ChatAction>? {

        return nil
    }
    public override func reduce(_ state: ChatState, _ action: ChatAction) -> ChatState {
        var newState = state
        switch action {
        case .checkPushNotificationStatus:
            newState.askedForPushNotificationsPermission = true
        case let .setAllowNewMessages(allow):
            newState.allowNewMessageToast = allow
        default:
            break
        }
        return newState
    }
}
