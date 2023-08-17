import Foundation
import Presentation
import hCore

public struct TerminationContract {
}

/* TODO: FIX THIS */
//extension TerminationContract {
//    public static func journey<ResultJourney: JourneyPresentation>(
////        filter: ContractFilter = .active(ifEmpty: .terminated(ifEmpty: .none)),
////        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney,
//        openDetails: Bool = true
//    ) -> some JourneyPresentation {
//        HostingJourney(
//            TerminationContractStore.self,
//            rootView: <#T##RootView#>
////            rootView: Contracts(filter: filter)
//        ) { action in
//
//            if case let .terminationInitialNavigation(navigationAction) = action {
//                if case .openTerminationSuccessScreen = navigationAction {
//                    TerminationFlowJourney.openTerminationSuccessScreen()
//                } else if case .openTerminationSetDateScreen = navigationAction {
//                    TerminationFlowJourney.openSetTerminationDateScreen()
//                } else if case .openTerminationFailScreen = navigationAction {
//                    TerminationFlowJourney.openTerminationFailScreen()
//                } else if case .openTerminationUpdateAppScreen = navigationAction {
//                    TerminationFlowJourney.openUpdateAppTerminationScreen()
//                } else if case .openTerminationDeletionScreen = navigationAction {
//                    TerminationFlowJourney.openTerminationDeletionScreen()
//                }
//            }
//        }
//    }
//}
