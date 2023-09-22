import Foundation
import Presentation
import hCore
import hCoreUI

public struct MovingFlowJourneyNew {

    @JourneyBuilder
    public static func getMovingFlowScreenForAction(
        for action: MoveFlowAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getMovingFlowScreen(for: action).hidesBackButton
        } else {
            getMovingFlowScreen(for: action).showsBackButton
        }
    }
    @JourneyBuilder
    public static func getMovingFlowScreen(for action: MoveFlowAction) -> some JourneyPresentation {
        if case let .navigation(navigationAction) = action {
            if case .openAddressFillScreen = navigationAction {
                MovingFlowJourneyNew.openApartmentFillScreen()
            } else if case .openHouseFillScreen = navigationAction {
                MovingFlowJourneyNew.openApartmentFillScreen()
            } else if case .openHousingTypeScreen = navigationAction {
                MovingFlowJourneyNew.openSelectHousingScreen()
            } else if case .openConfirmScreen = navigationAction {
                MovingFlowJourneyNew.openConfirmScreen()
            } else if case .openFailureScreen = navigationAction {
                MovingFlowJourneyNew.openFailureScreen().configureTitle(L10n.InsuranceDetails.changeAddressButton)
            } else if case .openProcessingView = navigationAction {
                MovingFlowJourneyNew.openProcessingView()
            } else if case .dismissMovingFlow = navigationAction {
                DismissJourney()
            } else if case .goToFreeTextChat = navigationAction {
                DismissJourney()
            } else if case .goBack = navigationAction {
                PopJourney()
            }
        }
    }

    public static func openSelectHousingScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowHousingTypeView(),
            style: .detented(.large),
            options: [
                .defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.always),
            ]
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    static func openApartmentFillScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowApartmentView()
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    static func openConfirmScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowConfirm()
        ) {
            action in
            getMovingFlowScreen(for: action).hidesBackButton
        }
        .configureTitle(L10n.changeAddressSummaryTitle)
        .withJourneyDismissButton
    }

    static func openProcessingView() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowProcessingView()
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
    }

    static func openFailureScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowFailure()
        ) {
            action in
            getMovingFlowScreenForAction(for: action, withHidesBack: true)
        }
        .withJourneyDismissButton
    }
}
