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
                .withJourneyDismissButton.hidesBackButton
        } else if case let .openTerminationSetDateScreen(context) = action {
            AppJourney.openSetTerminationDateScreen(context: context).withJourneyDismissButton
        } else if case .openTerminationFailScreen = action {
            AppJourney.openTerminationFailScreen().withJourneyDismissButton.hidesBackButton
        } else if case .openTerminationUpdateAppScreen = action {
            AppJourney.openUpdateAppTerminationScreen().hidesBackButton
        } else if case .dismissTerminationFlow = action {
            DismissJourney()
        } else if case .goToFreeTextChat = action {
            DismissJourney()
        }
    }

    static func openSetTerminationDateScreen(context: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: SetTerminationDate(
                onSelected: {
                    terminationDate in
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.send(.sendTerminationDate(terminationDateInput: terminationDate, contextInput: context))
                }
            ),
            style: .detented(.large)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openTerminationSuccessScreen(terminationDate: Date, surveyURL: String) -> some JourneyPresentation {

        HostingJourney(
            ContractStore.self,
            rootView: TerminationSuccessScreen(terminationDate: terminationDate, surveyURL: surveyURL)
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
}
