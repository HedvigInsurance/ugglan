import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class TerminationFlowJourney {

    public static func start(for action: TerminationNavigationAction) -> some JourneyPresentation {
        getScreen(for: .navigationAction(action: action)).hidesBackButton
    }

    @JourneyBuilder
    private static func getScreen(for action: TerminationContractAction) -> some JourneyPresentation {
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
    private static func openProgressScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: ProcessingView<TerminationContractStore, EmptyView>(
                showSuccessScreen: false,
                TerminationContractStore.self,
                loading: .sendTerminationDate,
                loadingViewText: L10n.terminateContractTerminatingProgress,
                onErrorCancelAction: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.dismissTerminationFlow)
                }
            )
        ) { action in
            getScreen(for: action)
        }
        .hidesBackButton
    }

    private static func openSetTerminationDateScreen() -> some JourneyPresentation {
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
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBarWithoutGrabber, .blurredBackground]
        ) {
            action in
            getScreen(for: action)
        }
        .configureTitle(L10n.setTerminationDateText)
    }

    private static func openConfirmTerminationScreen(config: TerminationConfirmConfig) -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: ConfirmTerminationScreen(
                config: config,
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    if store.state.config?.isDeletion ?? false {
                        store.send(.sendConfirmDelete)
                    } else {
                        store.send(.sendTerminationDate)
                    }
                    store.send(.navigationAction(action: .openTerminationProcessingScreen))
                }
            ),
            style: .modally(presentationStyle: .overFullScreen)
        ) {
            action in
            getScreen(for: action)
        }
        .configureTitle(L10n.terminationConfirmButton)
        .withJourneyDismissButton
    }

    private static func openTerminationSuccessScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: TerminationSuccessScreen()
        ) {
            action in
            getScreen(for: action)
        }
        .configureTitle(L10n.terminateContractConfirmationTitle)
        .withJourneyDismissButton
        .hidesBackButton
        .onDismiss {
            @PresentableStore var store: TerminationContractStore
            store.send(.dismissTerminationFlow)
        }
    }

    private static func openTerminationFailScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: GenericErrorView(
                title: L10n.terminationNotSuccessfulTitle,
                description: L10n.somethingWentWrong,
                icon: .triangle,
                buttons: .init(
                    actionButtonAttachedToBottom: .init(
                        buttonTitle: L10n.openChat,
                        buttonAction: {
                            let store: TerminationContractStore = globalPresentableStoreContainer.get()
                            store.send(.dismissTerminationFlow)
                            store.send(.goToFreeTextChat)
                        }
                    ),
                    dismissButton: .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            let store: TerminationContractStore = globalPresentableStoreContainer.get()
                            store.send(.dismissTerminationFlow)
                        }
                    )
                )
            ),
            style: .detented(.large, modally: true)
        ) {
            action in
            getScreen(for: action)
        }
        .hidesBackButton
    }

    private static func openUpdateAppTerminationScreen() -> some JourneyPresentation {
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
            getScreen(for: action)
        }
        .withJourneyDismissButton
        .hidesBackButton
    }

    private static func openTerminationDeletionScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: TerminationDeleteScreen(
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    if let config = store.state.config {
                        store.send(.setTerminationisDeletion)
                        store.send(.navigationAction(action: .openConfirmTerminationScreen(config: config)))
                    } else {
                        store.send(.navigationAction(action: .openTerminationFailScreen))
                    }
                }
            ),
            style: .detented(.scrollViewContentSize)
        ) {
            action in
            getScreen(for: action)
        }
        .withJourneyDismissButton
    }
}
