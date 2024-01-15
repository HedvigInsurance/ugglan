import Foundation
import Presentation
import hCore
import hCoreUI

public class ChatJourney {
    public static func start() -> some JourneyPresentation {
        return HostingJourney(
            ChatStore.self,
            rootView: ChatScreen(vm: .init()),
            style: .detented(.large),
            options: [.embedInNavigationController, .preffersLargerNavigationBar]
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .closeChat = navigationAction {
                    PopJourney()
                }
            }
        }
        .configureTitle(L10n.chatTitle)
        .setScrollEdgeNavigationBarAppearanceToStandardd
    }
}
