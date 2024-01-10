import Foundation
import Presentation
import hCore
import hCoreUI

public class ChatJourney {
    public static func start() -> some JourneyPresentation {
        return HostingJourney(
            rootView: ChatScreen(vm: .init()),
            style: .detented(.large),
            options: [.embedInNavigationController, .preffersLargerNavigationBar]
        )
        .configureTitle(L10n.chatTitle)
        .setScrollEdgeNavigationBarAppearanceToStandardd
    }
}
