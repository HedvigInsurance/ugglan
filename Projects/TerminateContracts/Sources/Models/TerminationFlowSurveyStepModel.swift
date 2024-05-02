import Foundation

struct TerminationFlowSurveyStepModel: FlowStepModel {
    let id: String
    let options: [TerminationFlowSurveyStepModelOption]
}

struct TerminationFlowSurveyStepModelOption: FlowStepModel, Identifiable {
    let id: String
    let title: String
    let suggestion: TerminationFlowSurveyStepSuggestion?
    let feedBack: TerminationFlowSurveyStepFeedback?
    let subOptions: [TerminationFlowSurveyStepModelOption]?
}

enum TerminationFlowSurveyStepSuggestion: FlowStepModel {
    case action(action: TerminationFlowSurveyStepSuggestionAction)
    case redirect(redirect: TerminationFlowSurveyStepSuggestionRedirection)
}

struct TerminationFlowSurveyStepSuggestionAction: FlowStepModel {
    let id: String
    let action: FlowTerminationSurveyRedirectAction
}

enum FlowTerminationSurveyRedirectAction: FlowStepModel {
    case updateAddress
    case messageUs
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
