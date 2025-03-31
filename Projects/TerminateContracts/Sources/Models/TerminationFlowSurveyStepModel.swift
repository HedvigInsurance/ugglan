import Foundation
import hCore
import hCoreUI

public struct TerminationFlowSurveyStepModel: FlowStepModel {
    let id: String
    var options: [TerminationFlowSurveyStepModelOption]
    var subTitleType: SurveyScreenSubtitleType

    public init(id: String, options: [TerminationFlowSurveyStepModelOption], subTitleType: SurveyScreenSubtitleType) {
        self.id = id
        self.options = options
        self.subTitleType = subTitleType
    }
}

public struct TerminationFlowSurveyStepModelOption: FlowStepModel, Identifiable {
    public let id: String
    let title: String
    let suggestion: TerminationFlowSurveyStepSuggestion?
    let feedBack: TerminationFlowSurveyStepFeedback?
    let subOptions: [TerminationFlowSurveyStepModelOption]?

    public init(
        id: String,
        title: String,
        suggestion: TerminationFlowSurveyStepSuggestion?,
        feedBack: TerminationFlowSurveyStepFeedback?,
        subOptions: [TerminationFlowSurveyStepModelOption]?
    ) {
        self.id = id
        self.title = title
        self.suggestion = suggestion
        self.feedBack = feedBack
        self.subOptions = subOptions
    }
}

public enum TerminationFlowSurveyStepSuggestion: FlowStepModel {
    case action(action: TerminationFlowSurveyStepSuggestionAction)
    case redirect(redirect: TerminationFlowSurveyStepSuggestionRedirection)
    case suggestionInfo(info: TerminationFlowSurveyStepSuggestionInfo)
}

public struct TerminationFlowSurveyStepSuggestionAction: FlowStepModel {
    let id: String
    public let action: FlowTerminationSurveyRedirectAction
    let description: String
    let buttonTitle: String
    let type: SurveySuggestionInfoType

    public init(
        id: String,
        action: FlowTerminationSurveyRedirectAction,
        description: String,
        buttonTitle: String,
        type: SurveySuggestionInfoType
    ) {
        self.id = id
        self.action = action
        self.description = description
        self.buttonTitle = buttonTitle
        self.type = type
    }
}

public enum FlowTerminationSurveyRedirectAction: FlowStepModel {
    case updateAddress
    case changeTierFoundBetterPrice
    case changeTierMissingCoverageAndTerms
}

public struct TerminationFlowSurveyStepSuggestionRedirection: FlowStepModel {
    let id: String
    let url: String
    let description: String
    let buttonTitle: String
    let type: SurveySuggestionInfoType

    public init(id: String, url: String, description: String, buttonTitle: String, type: SurveySuggestionInfoType) {
        self.id = id
        self.url = url
        self.description = description
        self.buttonTitle = buttonTitle
        self.type = type
    }
}

public struct TerminationFlowSurveyStepSuggestionInfo: FlowStepModel {
    let id: String
    let description: String
    let type: SurveySuggestionInfoType

    public init(id: String, description: String, type: SurveySuggestionInfoType) {
        self.id = id
        self.description = description
        self.type = type
    }
}

public struct TerminationFlowSurveyStepFeedback: FlowStepModel {
    let id: String
    let isRequired: Bool

    public init(id: String, isRequired: Bool) {
        self.id = id
        self.isRequired = isRequired
    }
}

public enum SurveySuggestionInfoType: Codable, Sendable {
    case info
    case offer

    var notificationType: NotificationType {
        switch self {
        case .info:
            return .info
        case .offer:
            return .campaign
        }
    }
}

public enum SurveyScreenSubtitleType: Codable, Sendable {
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
