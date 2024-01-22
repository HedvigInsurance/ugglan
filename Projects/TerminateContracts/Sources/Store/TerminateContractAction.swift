import Foundation
import Presentation

public enum TerminationStepModelAction: ActionProtocol, Hashable {
    case setTerminationDateStep(model: TerminationFlowDateNextStepModel)
    case setTerminationDeletion(model: TerminationFlowDeletionNextModel)
    case setSuccessStep(model: TerminationFlowSuccessNextModel)
    case setFailedStep(model: TerminationFlowFailedNextModel)
}

public enum TerminationContractAction: ActionProtocol, Hashable {
    case stepModelAction(action: TerminationStepModelAction)
    case navigationAction(action: TerminationNavigationAction)
    case terminationInitialNavigation(action: TerminationNavigationAction)

    case startTermination(contractId: String, contractName: String)
    case setTerminationDate(terminationDate: Date)
    case sendTerminationDate
    case deleteTermination
    case setTerminationContext(context: String)
    case setTerminationContractId(id: String)
    case setTerminationConfig(config: TerminationConfirmConfig)

    case sendTermination(terminationDate: Date, surveyUrl: String)
    case dismissTerminationFlow
    case goToFreeTextChat
    case goToUrl(url: URL)
}

public enum TerminationNavigationAction: ActionProtocol, Hashable {
    case openTerminationSuccessScreen
    case openTerminationUpdateAppScreen
    case openTerminationFailScreen
    case openTerminationDeletionScreen
    case openSetTerminationDateScreen
    case openConfirmTerminationScreen(config: TerminationConfirmConfig?)
    case openTerminationProcessingScreen
}

public enum TerminationContractLoadingAction: LoadingProtocol {
    case startTermination
    case sendTerminationDate
    case deleteTermination
}
