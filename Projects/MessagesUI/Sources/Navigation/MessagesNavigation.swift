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

/// The Messages inbox in its own navigation stack, for presenting modally; opened messages push inside it.
public struct MessagesNavigation: View {
    public init() {}

    public var body: some View {
        MessagesInboxScreen()
            .withDismissButton()
            .messagesRouterDestinations()
            .embededInNavigation(options: [.extendedNavigationWidth], tracking: MessagesRouterAction.inbox)
    }
}

extension View {
    /// Registers the opened-message screen on the enclosing `hNavigationStack`, so it can be pushed with
    /// `router.push(MessagesRouterAction.message(id:))`.
    func messagesRouterDestinations() -> some View {
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
