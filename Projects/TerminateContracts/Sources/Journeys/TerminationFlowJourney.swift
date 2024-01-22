import Foundation
import Presentation
import hCore
import hCoreUI

public class TerminationFlowJourney {

    public static func start(for action: TerminationNavigationAction) -> some JourneyPresentation {
        getScreenForAction(for: .navigationAction(action: action), withHidesBack: true)
    }

    @JourneyBuilder
    static func getScreenForAction(
        for action: TerminationContractAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getScreen(for: action).hidesBackButton
        } else {
            getScreen(for: action).showsBackButton
        }
    }

    @JourneyBuilder
    static func getScreen(for action: TerminationContractAction) -> some JourneyPresentation {
        if case let .navigationAction(navigationAction) = action {
            if case .openTerminationSuccessScreen = navigationAction {
                TerminationFlowJourney.openTerminationSuccessScreen()
            } else if case .openSetTerminationDateScreen = navigationAction {
                TerminationFlowJourney.openSetTerminationDateScreen()
            } else if case .openTerminationFailScreen = navigationAction {
                TerminationFlowJourney.openTerminationFailScreen()
            } else if case .openTerminationUpdateAppScreen = navigationAction {
                TerminationFlowJourney.openUpdateAppTerminationScreen()
            } else if case .openTerminationDeletionScreen = navigationAction {
                TerminationFlowJourney.openTerminationDeletionScreen()
            } else if case let .openConfirmTerminationScreen(config) = navigationAction {
                openConfirmTerminationScreen(config: config)
            } else if case .openTerminationProcessingScreen = navigationAction {
                openProgressScreen()
            }
        } else if case .dismissTerminationFlow = action {
            DismissJourney()
        } else if case .goToFreeTextChat = action {
            DismissJourney()
        }
    }

    @JourneyBuilder
    static func openProgressScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: ProcessingView(
                TerminationContractStore.self,
                loading: .sendTerminationDate,
                loadingViewText: L10n.terminateContractTerminatingProgress,
                onDismiss: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.dismissTerminationFlow)
                }
            ),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
    }

    static func openSetTerminationDateScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: SetTerminationDate(
                onSelected: {
                    terminationDate in
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.setTerminationDate(terminationDate: terminationDate))
                    if let config = store.state.config {
                        store.send(.navigationAction(action: .openConfirmTerminationScreen(config: config)))
                    } else {
                        store.send(.navigationAction(action: .openTerminationFailScreen))
                    }
                }
            ),
            style: .detented(.large)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .withJourneyDismissButton
    }

    static func openConfirmTerminationScreen(config: TerminationConfirmConfig) -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: ConfirmTerminationScreen(
                config: config,
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.sendTerminationDate)
                    store.send(.navigationAction(action: .openTerminationProcessingScreen))
                }
            ),
            style: .detented(.large)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .configureTitle(L10n.terminationConfirmButton)
        .withJourneyDismissButton
    }

    static func openTerminationSuccessScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: TerminationSuccessScreen()
        ) {
            action in
            getScreenForAction(for: action)
        }
        .configureTitle(L10n.terminateContractConfirmationTitle)
        .withJourneyDismissButton
        .hidesBackButton
        .onDismiss {
            @PresentableStore var store: TerminationContractStore
            store.send(.dismissTerminationFlow)
        }
    }

    static func openTerminationFailScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
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
            TerminationContractStore.self,
            rootView: UpdateAppScreen(
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
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
            TerminationContractStore.self,
            rootView: TerminationDeleteScreen(
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
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
