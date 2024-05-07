import Foundation
import hCore

public struct TerminationFlowSurveyStepModel: FlowStepModel {
    let id: String
    let options: [TerminationFlowSurveyStepModelOption]
}

public struct TerminationFlowSurveyStepModelOption: FlowStepModel, Identifiable {
    public let id: String
    let title: String
    let suggestion: TerminationFlowSurveyStepSuggestion?
    let feedBack: TerminationFlowSurveyStepFeedback?
    let subOptions: [TerminationFlowSurveyStepModelOption]?
}

enum TerminationFlowSurveyStepSuggestion: FlowStepModel {
    case action(action: TerminationFlowSurveyStepSuggestionAction)
    case redirect(redirect: TerminationFlowSurveyStepSuggestionRedirection)
}

public struct TerminationFlowSurveyStepSuggestionAction: FlowStepModel {
    let id: String
    public let action: FlowTerminationSurveyRedirectAction
}

public enum FlowTerminationSurveyRedirectAction: FlowStepModel {
    case updateAddress

    var title: String {
        switch self {
        case .updateAddress:
            return L10n.terminationSurveyMovingSuggestion
        }
    }

    var buttonTitle: String {
        switch self {
        case .updateAddress:
            return L10n.terminationSurveyMovingButton
        }
    }
}

struct TerminationFlowSurveyStepSuggestionRedirection: FlowStepModel {
    let id: String
    let url: String
    let description: String
    let buttonTitle: String
}

struct TerminationFlowSurveyStepFeedback: FlowStepModel {
    let id: String
    let isRequired: Bool
}
