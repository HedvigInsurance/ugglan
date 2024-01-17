import Flow
import Foundation
import Presentation

public struct ChatState: StateProtocol {
    public init() {}
}

public enum ChatAction: ActionProtocol {
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
        return newState
    }
}
