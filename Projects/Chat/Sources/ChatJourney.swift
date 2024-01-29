import Foundation
import Presentation
import hCore
import hCoreUI

public class ChatJourney {
    public static func start<ResultJourney: JourneyPresentation>(
        topic: ChatTopicType?,
        style: PresentationStyle,
        @JourneyBuilder resultJourney: @escaping (_ result: ChatResult) -> ResultJourney

    ) -> some JourneyPresentation {
        return HostingJourney(
            ChatStore.self,
            rootView: ChatScreen(vm: .init(topicType: topic)),
            style: style,
            options: [
                .embedInNavigationController,
                .preffersLargerNavigationBar,
                .ignoreSizeChange,
            ]
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .closeChat = navigationAction {
                    PopJourney()
                } else if case let .linkClicked(link) = navigationAction {
                    if let deepLink = DeepLink.getType(from: link), deepLink.tabURL {
                        PopJourney()
                    }
                }
            } else if case .checkPushNotificationStatus = action {
                resultJourney(.notifications)
            }
        }
        .configureTitle(L10n.chatTitle)
        .setScrollEdgeNavigationBarAppearanceToStandardd
        .onPresent {
            let store: ChatStore = globalPresentableStoreContainer.get()
            store.send(.setAllowNewMessages(allow: false))
        }
        .onDismiss {
            let store: ChatStore = globalPresentableStoreContainer.get()
            store.send(.setAllowNewMessages(allow: true))
        }
    }
}
public enum ChatResult {
    case notifications
}
