import Contracts
import Presentation
import hCore

extension AppJourney {
    static func terminationFlow(contractId: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: SetTerminationDate(contractId: contractId),
            style: .modal
        ) {
            action in
            if case .sendTermination = action {
                sendTermination()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
        .withDismissButton
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
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
}
