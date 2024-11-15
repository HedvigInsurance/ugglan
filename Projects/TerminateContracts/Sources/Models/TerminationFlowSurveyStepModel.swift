import Foundation
import hCore

public struct TerminationFlowSurveyStepModel: FlowStepModel {
    let id: String
    var options: [TerminationFlowSurveyStepModelOption]
    var subTitleType: SurveyScreenSubtitleType
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
    let description: String
    let buttonTitle: String
}

public enum FlowTerminationSurveyRedirectAction: FlowStepModel {
    case updateAddress
    case changeTierFoundBetterPrice
    case changeTierMissingCoverageAndTerms
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

public enum SurveyScreenSubtitleType: Codable {
    case `default`
    case generic

    var title: String {
        switch self {
        case .default:
            return L10n.terminationSurveySubtitle
        case .generic:
            return L10n.terminationSurveyGenericSubtitle
        }
    }
}
