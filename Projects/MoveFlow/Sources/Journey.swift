import Foundation
import Presentation
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowJourneyNew {

    public static func startMovingFlow() -> some JourneyPresentation {
        openSelectHousingScreen()
    }

    @JourneyBuilder
    static func getMovingFlowScreenForAction(
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
    static func getMovingFlowScreen(for action: MoveFlowAction) -> some JourneyPresentation {
        if case let .navigation(navigationAction) = action {
            if case .openAddressFillScreen = navigationAction {
                MovingFlowJourneyNew.openApartmentFillScreen()
            } else if case .openHouseFillScreen = navigationAction {
                MovingFlowJourneyNew.openHouseFillScreen()
            } else if case .openConfirmScreen = navigationAction {
                MovingFlowJourneyNew.openConfirmScreen()
            } else if case let .openFailureScreen(error) = navigationAction {
                MovingFlowJourneyNew.openFailureScreen(with: error)
                    .configureTitle(L10n.InsuranceDetails.changeAddressButton)
            } else if case .openProcessingView = navigationAction {
                MovingFlowJourneyNew.openProcessingView()
            } else if case .dismissMovingFlow = navigationAction {
                DismissJourney()
            } else if case .goBack = navigationAction {
                PopJourney()
            }
        }
    }

    static func openSelectHousingScreen() -> some JourneyPresentation {
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
            rootView: MovingFlowNewAddressView()
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    static func openHouseFillScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowHouseView()
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

    static func openFailureScreen(with error: String) -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowFailure(error: error)
        ) {
            action in
            getMovingFlowScreenForAction(for: action, withHidesBack: true)
        }
        .withJourneyDismissButton
    }
}
