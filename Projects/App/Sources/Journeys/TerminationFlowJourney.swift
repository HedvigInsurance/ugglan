import Contracts
import Presentation
import hCore

extension AppJourney {
    static func terminationFlow(contractId: String, context: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: SetTerminationDate(contractId: contractId, context: context),
            style: .modal
        ) {
            action in
            if case .sendTermination(let terminationDate, let context, let surveyURL) = action {
                sendTermination(terminationDate: terminationDate, surveyURL: surveyURL)
            } else if case .terminationFail = action {
                terminationFail()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
        .withDismissButton
    }

    static func sendTermination(terminationDate: String, surveyURL: String) -> some JourneyPresentation {

        HostingJourney(
            ContractStore.self,
            rootView: TerminationSuccessScreen(terminationDate: terminationDate, surveyURL: surveyURL),
            style: .modal
        ) {
            action in
            if case .dismissTerminationFlow = action {
                DismissJourney()
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func terminationFail() -> some JourneyPresentation {

        HostingJourney(
            ContractStore.self,
            rootView: TerminationFailScreen(),
            style: .modal
        ) {
            action in
            if case .dismissTerminationFlow = action {
                DismissJourney()
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
}
