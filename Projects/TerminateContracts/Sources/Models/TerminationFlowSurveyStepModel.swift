import Foundation
import hCore

public struct TerminationSurveyData: Codable, Equatable, Hashable, Sendable {
    public let options: [TerminationSurveyOption]
    public let action: TerminationAction

    public init(options: [TerminationSurveyOption], action: TerminationAction) {
        self.options = options
        self.action = action
    }
}

public struct TerminationSurveyOption: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let feedbackRequired: Bool
    public let suggestion: TerminationSuggestion?
    public let subOptions: [TerminationSurveyOption]

    public init(
        id: String,
        title: String,
        feedbackRequired: Bool,
        suggestion: TerminationSuggestion?,
        subOptions: [TerminationSurveyOption]
    ) {
        self.id = id
        self.title = title
        self.feedbackRequired = feedbackRequired
        self.suggestion = suggestion
        self.subOptions = subOptions
    }
}

public struct TerminationSuggestion: Codable, Equatable, Hashable, Sendable {
    public let type: TerminationSuggestionType
    public let description: String
    public let url: String?

    public init(type: TerminationSuggestionType, description: String, url: String?) {
        self.type = type
        self.description = description
        self.url = url
    }

    public var isBlocking: Bool {
        switch type {
        case .updateAddress, .upgradeCoverage, .downgradePrice, .redirect:
            return true
        case .info, .autoCancelSold, .autoCancelScrapped, .autoDecommission,
            .carDecommissionInfo, .carAlreadyDecommission, .unknown:
            return false
        }
    }

    public var isDeflect: Bool {
        switch type {
        case .autoCancelSold, .autoCancelScrapped, .autoDecommission,
            .carDecommissionInfo, .carAlreadyDecommission:
            return true
        default:
            return false
        }
    }
}

public enum TerminationSuggestionType: String, Codable, Sendable {
    case updateAddress
    case upgradeCoverage
    case downgradePrice
    case redirect
    case info
    case autoCancelSold
    case autoCancelScrapped
    case autoDecommission
    case carDecommissionInfo
    case carAlreadyDecommission
    case unknown
}

public enum TerminationAction: Codable, Equatable, Hashable, Sendable {
    case terminateWithDate(minDate: String, maxDate: String, extraCoverage: [ExtraCoverageItem])
    case deleteInsurance(extraCoverage: [ExtraCoverageItem])
}

public enum TerminationContractResult: Equatable, Sendable {
    case success
    case userError(message: String)
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
