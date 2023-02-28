import Contracts
import Presentation
import hCore

extension AppJourney {
    static var terminationFlow: some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: SetTerminationDate(),
            style: .modal
        ) {
            action in
            if case .sendTermination = action {
                sendTermination()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
        .withJourneyDismissButton
    }

    static func sendTermination() -> some JourneyPresentation {

        HostingJourney(
            ContractStore.self,
            rootView: TerminationSuccessScreen(),
            style: .modal
        ) {
            action in
            if case .dismissTerminationFlow = action {
                DismissJourney()
            }
        }
        .withJourneyDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
}
