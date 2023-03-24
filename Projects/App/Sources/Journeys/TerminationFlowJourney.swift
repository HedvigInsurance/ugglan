import Contracts
import Foundation
import Presentation
import hCore

extension AppJourney {
    static func terminationFlow(contractId: String, context: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: SetTerminationDate(contractId: contractId, context: context),
            style: .modally()
        ) {
            action in
            if case .sendTermination(let terminationDate, _, let surveyURL) = action {
                sendTermination(terminationDate: terminationDate, surveyURL: surveyURL)
            } else if case .terminationFail = action {
                terminationFail()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
        .withJourneyDismissButton
    }

    static func sendTermination(terminationDate: Date, surveyURL: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: TerminationSuccessScreen(terminationDate: terminationDate, surveyURL: surveyURL),
            style: .default
        ) {
            action in
            if case .dismissTerminationFlow = action {
                DismissJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
        .withJourneyDismissButton
    }

    static func terminationFail() -> some JourneyPresentation {

        HostingJourney(
            ContractStore.self,
            rootView: TerminationFailScreen(),
            style: .default
        ) {
            action in
            if case .dismissTerminationFlow = action {
                DismissJourney()
            } else if case .goToFreeTextChat = action {
                DismissJourney()
            }
        }
        .withJourneyDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
}
