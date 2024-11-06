import Foundation
import PresentableStore

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
    case setProgress(progress: Float?)
    case sethaveSelectInsuranceStep(to: Bool)
}

public enum TerminationNavigationAction: ActionProtocol, Hashable {
    case openTerminationSuccessScreen
    case openTerminationUpdateAppScreen
    case openTerminationFailScreen
    case openSetTerminationDateLandingScreen(with: TerminationConfirmConfig)
    case openTerminationSurveyStep(
        options: [TerminationFlowSurveyStepModelOption],
        subtitleType: SurveyScreenSubtitleType
    )
}

public enum TerminationContractLoadingAction: LoadingProtocol {
    case getInitialStep
    case sendTerminationDate
    case sendSurvey
}
