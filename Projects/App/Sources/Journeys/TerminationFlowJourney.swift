import Contracts
import Foundation
import Presentation
import hCore
import hCoreUI

extension AppJourney {

    @JourneyBuilder
    private static func getScreenForAction(for action: ContractAction) -> some JourneyPresentation {
        if case .openTerminationSuccess = action {
            AppJourney.openTerminationSuccessScreen()
                .withJourneyDismissButton.hidesBackButton
        } else if case .openTerminationSetDateScreen = action {
            AppJourney.openSetTerminationDateScreen().withJourneyDismissButton
        } else if case .openTerminationFailScreen = action {
            AppJourney.openTerminationFailScreen().withJourneyDismissButton.hidesBackButton
        } else if case .openTerminationUpdateAppScreen = action {
            AppJourney.openUpdateAppTerminationScreen().hidesBackButton
        } else if case .dismissTerminationFlow = action {
            DismissJourney()
        } else if case .goToFreeTextChat = action {
            DismissJourney()
        } else if case .openTerminationDeletionScreen = action {
            AppJourney.openTerminationDeletionScreen()
        }
    }

    static func openSetTerminationDateScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: SetTerminationDate(
                onSelected: {
                    terminationDate in
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.send(.sendTerminationDate(terminationDate: terminationDate))
                }
            ),
            style: .detented(.large)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openTerminationSuccessScreen() -> some JourneyPresentation {

        HostingJourney(
            ContractStore.self,
            rootView: TerminationSuccessScreen()
        ) {
            action in
            getScreenForAction(for: action)
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openTerminationFailScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: TerminationFailScreen()
        ) {
            action in
            getScreenForAction(for: action)
        }
        .setScrollEdgeNavigationBarAppearanceToStandard

    }

    static func openUpdateAppTerminationScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: UpdateAppScreen(
                onSelected: {
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.send(.dismissTerminationFlow)
                }
            ),
            style: .detented(.large, modally: true)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    static func openTerminationDeletionScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: Termina(//                onSelected: {
                //                    let store: ContractStore = globalPresentableStoreContainer.get()
                //                    store.send(.dismissTerminationFlow)
                //                }
                ),
            style: .detented(.large, modally: true)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }
}
