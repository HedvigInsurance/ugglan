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
        GroupJourney {
            if case let .navigation(navigationAction) = action {
                if case .openAddressFillScreen = navigationAction {
                    MovingFlowJourneyNew.openAddressFillScreen()
                } else if case .openHousingTypeScreen = navigationAction {
                    MovingFlowJourneyNew.openSelectHousingScreen()
                } else if case .openConfirmScreen = navigationAction {
                    MovingFlowJourneyNew.openConfirmScreen()
                } else if case .openFailureScreen = navigationAction {
                    MovingFlowJourneyNew.openFailureScreen().configureTitle(L10n.InsuranceDetails.changeAddressButton)
                } else if case .dismissMovingFlow = navigationAction {
                    DismissJourney()
                } else if case .openDatePickerScreen = navigationAction {
                    MovingFlowJourneyNew.openDatePickerScreen()
                } else if case .goToFreeTextChat = navigationAction {
                    DismissJourney()
                }
            }
        }
    }

    @JourneyBuilder
    public static func openSelectHousingScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowHousingType(),
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

    @JourneyBuilder
    static func openAddressFillScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowSelectAddress()
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    @JourneyBuilder
    static func openConfirmScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowConfirm()
        ) {
            action in
            //            if case .navigationActionMovingFlow(.openAddressFillScreen) = action {
            //                PopJourney()
            //            } else {
            getMovingFlowScreenForAction(for: action)
            //            }
        }
        .withJourneyDismissButton
    }

    @JourneyBuilder
    static func openDatePickerScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: GeneralDatePicker(
                GeneralDatePickerViewModel(
                    title: "title",
                    buttonTitle: "button title",
                    onDateSelected: { movingDate in
                        //                        let store: ContractStore = globalPresentableStoreContainer.get()
                        //                        store.send(.setMovingDate(movingDate: movingDate))
                    }
                )
            ),
            style: .detented(.scrollViewContentSize)
        ) {
            action in
            //            if case .setMovingDate = action {
            PopJourney()
            //            } else {
            //                getMovingFlowScreenForAction(for: action)
            //            }
        }
        .withJourneyDismissButton
    }

    @JourneyBuilder
    static func openFailureScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowFailure()
        ) {
            action in
            getMovingFlowScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }
}
