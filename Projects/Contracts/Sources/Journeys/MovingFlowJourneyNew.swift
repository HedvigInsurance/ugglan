import Foundation
import Presentation
import hCore
import hCoreUI

public struct MovingFlowJourneyNew {

    @JourneyBuilder
    public static func getScreenForAction(
        for action: ContractAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getScreen(for: action).hidesBackButton
        } else {
            getScreen(for: action).showsBackButton
        }
    }

    @JourneyBuilder
    public static func getScreen(for action: ContractAction) -> some JourneyPresentation {
        GroupJourney {
            if case let .navigationActionMovingFlow(navigationAction) = action {
                if case .openAddressFillScreen = navigationAction {
                    MovingFlowJourneyNew.openAddressFillScreen()
                }
            }
        }
    }

    static func openAddressFillScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: MovingFlowSelectAddress(),
            style: .detented(.large)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

}
