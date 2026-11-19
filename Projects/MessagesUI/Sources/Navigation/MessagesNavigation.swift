import SwiftUI
import hCore
import hCoreUI

public enum MessagesRouterAction: Hashable, TrackingViewNameProtocol {
    case inbox
    case message(id: String)

    public var nameForTracking: String {
        switch self {
        case .inbox: String(describing: MessagesInboxScreen.self)
        case .message: String(describing: MessageDetailScreen.self)
        }
    }
}

extension View {
    /// Registers the Messages screens on the enclosing `hNavigationStack`, so they can be pushed with
    /// `router.push(MessagesRouterAction.inbox)`.
    public func messagesRouterDestinations() -> some View {
        routerDestination(for: MessagesRouterAction.self) { action in
            switch action {
            case .inbox:
                MessagesInboxScreen()
            case let .message(id):
                MessageDetailScreen(messageId: id)
            }
        }
    }
}
