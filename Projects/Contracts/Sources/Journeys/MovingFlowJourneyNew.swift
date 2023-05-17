import Foundation
import Presentation
import hCore
import hCoreUI

public struct MovingFlowJourneyNew {

    @JourneyBuilder
    public static func getMovingFlowScreenForAction(
        for action: ContractAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getMovingFlowScreen(for: action).hidesBackButton
        } else {
            getMovingFlowScreen(for: action).showsBackButton
        }
    }

    @JourneyBuilder
    public static func getMovingFlowScreen(for action: ContractAction) -> some JourneyPresentation {
        GroupJourney {
            if case let .navigationActionMovingFlow(navigationAction) = action {
                if case .openAddressFillScreen = navigationAction {
                    MovingFlowJourneyNew.openAddressFillScreen()
                } else if case .openHousingTypeScreen = navigationAction {
                    MovingFlowJourneyNew.openSelectHousingScreen()
                } else if case .openConfirmScreen = navigationAction {
                    MovingFlowJourneyNew.openConfirmScreen()
                }
            }
        }
    }

    @JourneyBuilder
    static func openAddressFillScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: MovingFlowSelectAddress()
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    @JourneyBuilder
    public static func openSelectHousingScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: MovingFlowHousingType()
                //            style: .detented(.large),
                //            options: [
                //                .defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.always),
                //            ]
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    @JourneyBuilder
    static func openConfirmScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: MovingFlowConfirm()
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }
}
