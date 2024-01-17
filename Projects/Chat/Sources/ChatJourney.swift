import Foundation
import Presentation
import hCore
import hCoreUI

public class ChatJourney {
    public static func start<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: ChatResult) -> ResultJourney

    ) -> some JourneyPresentation {
        return HostingJourney(
            ChatStore.self,
            rootView: ChatScreen(vm: .init()),
            style: .detented(.large),
            options: [
                .embedInNavigationController,
                .preffersLargerNavigationBar,
                .ignoreSizeChange,
            ]
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .closeChat = navigationAction {
                    PopJourney()
                }
            } else if case .checkPushNotificationStatus = action {
                resultJourney(.notifications)
            }
        }
        .configureTitle(L10n.chatTitle)
        .setScrollEdgeNavigationBarAppearanceToStandardd
    }
}
public enum ChatResult {
    case notifications

}
