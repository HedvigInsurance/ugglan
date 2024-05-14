import Foundation
import Presentation

public enum TerminationStepModelAction: ActionProtocol, Hashable {
    case setTerminationDateStep(model: TerminationFlowDateNextStepModel)
    case setTerminationDeletion(model: TerminationFlowDeletionNextModel)
    case setSuccessStep(model: TerminationFlowSuccessNextModel)
    case setFailedStep(model: TerminationFlowFailedNextModel)
    case setTerminationSurveyStep(model: TerminationFlowSurveyStepModel)
}

public enum TerminationContractAction: ActionProtocol, Hashable {
    case stepModelAction(action: TerminationStepModelAction)
    case navigationAction(action: TerminationNavigationAction)

    case submitSurvey(option: String, feedback: String?)

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
    case openTerminationSurveyStep(options: [TerminationFlowSurveyStepModelOption])
    case openRedirectAction(action: FlowTerminationSurveyRedirectAction)
    case openRedirectUrl(url: URL)
}

public enum TerminationContractLoadingAction: LoadingProtocol {
    case getInitialStep
    case sendTerminationDate
    case sendSurvey
}
