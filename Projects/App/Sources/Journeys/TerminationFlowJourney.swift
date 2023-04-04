import Contracts
import Foundation
import Presentation
import hCore
import hCoreUI

extension AppJourney {

    @JourneyBuilder
    private static func getScreenForAction(for action: ContractAction) -> some JourneyPresentation {
        GroupJourney {
            if case let .navigationAction(navigationAction) = action {
                if case .openTerminationSuccessScreen = navigationAction {
                    AppJourney.openTerminationSuccessScreen()
                } else if case .openTerminationSetDateScreen = navigationAction {
                    AppJourney.openSetTerminationDateScreen()
                } else if case .openTerminationFailScreen = navigationAction {
                    AppJourney.openTerminationFailScreen()
                } else if case .openTerminationUpdateAppScreen = navigationAction {
                    AppJourney.openUpdateAppTerminationScreen()
                } else if case .openTerminationDeletionScreen = navigationAction {
                    AppJourney.openTerminationDeletionScreen()
                }
            } else if case .dismissTerminationFlow = action {
                DismissJourney()
            } else if case .goToFreeTextChat = action {
                DismissJourney()
            }
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
        .withJourneyDismissButton
    }

    static func openTerminationSuccessScreen() -> some JourneyPresentation {

        HostingJourney(
            ContractStore.self,
            rootView: TerminationSuccessScreen()
        ) {
            action in
            getScreenForAction(for: action)
        }
        .withJourneyDismissButton
        .hidesBackButton
        .onDismiss {
            @PresentableStore var store: ContractStore
            store.send(.dismissTerminationFlow)
        }
    }

    static func openTerminationFailScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: TerminationFailScreen()
        ) {
            action in
            getScreenForAction(for: action)
        }
        .withJourneyDismissButton
        .hidesBackButton

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
        .hidesBackButton
    }

    static func openTerminationDeletionScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: TerminationDeleteScreen(
                onSelected: {
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.send(.deleteTermination)
                }
            ),
            style: .detented(.large, modally: true)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }
}
