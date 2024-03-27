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

    case startTermination(config: TerminationConfirmConfig)
    case setTerminationDate(terminationDate: Date)
    case sendTerminationDate
    case sendConfirmDelete
    case setTerminationContext(context: String)

    case sendTermination(terminationDate: Date, surveyUrl: String)
    case dismissTerminationFlow(afterCancellationFinished: Bool)
    case dismissDatePicker
    case goBack
    case goToFreeTextChat
    case goToUrl(url: URL)
}

public enum TerminationNavigationAction: ActionProtocol, Hashable {
    case openTerminationSuccessScreen
    case openTerminationUpdateAppScreen
    case openTerminationFailScreen
    case openTerminationDatePickerScreen
    case openConfirmTerminationScreen
    case openTerminationProcessingScreen
    case openSelectInsuranceScreen(configs: [TerminationConfirmConfig])
    case openSetTerminationDateLandingScreen(with: TerminationConfirmConfig)
}

public enum TerminationContractLoadingAction: LoadingProtocol {
    case getInitialStep
    case sendTerminationDate
}
