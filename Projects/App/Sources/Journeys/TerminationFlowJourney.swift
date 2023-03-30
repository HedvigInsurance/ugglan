import Contracts
import Foundation
import Presentation
import hCore
import hCoreUI

extension AppJourney {

    @JourneyBuilder
    private static func getScreenForAction(for action: ContractAction) -> some JourneyPresentation {
        if case let .openTerminationSuccess(terminationDateInput, surveyURL) = action {
            AppJourney.openTerminationSuccessScreen(terminationDate: terminationDateInput, surveyURL: surveyURL)
                .withJourneyDismissButton
        } else if case let .openTerminationSetDateScreen(context) = action {
            AppJourney.openSetTerminationDateScreen(context: context).withJourneyDismissButton
        } else if case .openTerminationFailScreen = action {
            AppJourney.openTerminationFailScreen().withJourneyDismissButton
        } else if case .openTerminationUpdateAppScreen = action {
            AppJourney.openUpdateAppTerminationScreen().withJourneyDismissButton
        }
    }

    static func openSetTerminationDateScreen(context: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: SetTerminationDate(),
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .onAction(
            ContractStore.self,
            { action, pre in
                if case let .submitTerminationDate(terminationDate) = action {
                    @PresentableStore var store: ContractStore
                    store.send(.sendTerminationDate(terminationDateInput: terminationDate, contextInput: context))
                } else if case .dismissTerminationFlow = action {
                    pre.bag.dispose()
                } else if case .goToFreeTextChat = action {
                    pre.bag.dispose()
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openTerminationSuccessScreen(terminationDate: Date, surveyURL: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: TerminationSuccessScreen(terminationDate: terminationDate, surveyURL: surveyURL),
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .onAction(
            ContractStore.self,
            { action, pre in
                if case .dismissTerminationFlow = action {
                    pre.bag.dispose()
                } else if case .goToFreeTextChat = action {
                    pre.bag.dispose()
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openTerminationFailScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: TerminationFailScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .onAction(
            ContractStore.self,
            { action, pre in
                if case .dismissTerminationFlow = action {
                    pre.bag.dispose()
                } else if case .goToFreeTextChat = action {
                    pre.bag.dispose()
                }
            }
        )
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
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .onAction(
            ContractStore.self,
            { action, pre in
                if case .dismissTerminationFlow = action {
                    pre.bag.dispose()
                } else if case .goToFreeTextChat = action {
                    pre.bag.dispose()
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
}
