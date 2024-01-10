import Flow
import Foundation
import Presentation

struct ChatState: StateProtocol {
    init() {}
}

enum ChatAction: ActionProtocol {
    case redirectAction
}

final class ChatStore: StateStore<ChatState, ChatAction> {
}
