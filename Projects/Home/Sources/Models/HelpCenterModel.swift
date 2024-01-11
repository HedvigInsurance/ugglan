import Foundation
import hCore
import hGraphQL

public struct HelpCenterModel: Codable, Equatable, Hashable {
    let title: String
    let description: String
    let quickActions: [QuickAction]
    let commonTopics: [CommonTopic]
    let commonQuestions: [Question]
}

public enum QuickAction: Codable, Equatable, Hashable {
    case changeBank
    case updateAddress
    case editCoInsured
    case travelCertificate

    var title: String {
        switch self {
        case .changeBank:
            return L10n.hcQuickActionsChangeBank
        case .updateAddress:
            return L10n.hcQuickActionsUpdateAddress
        case .editCoInsured:
            return L10n.hcQuickActionsEditCoinsured
        case .travelCertificate:
            return L10n.hcQuickActionsTravelCertificate
        }
    }
}

public struct CommonTopic: Codable, Equatable, Hashable {
    let title: String
    let commonQuestions: [Question]
    let allQuestions: [Question]
}

public struct Question: Codable, Equatable, Hashable {
    let question: String
    let answer: String
    let relatedQuestions: [Question]

    public init(question: String, answer: String, relatedQuestions: [Question]) {
        var answer = answer
        if Environment.staging == Environment.current {
            answer =
                answer
                .replacingOccurrences(
                    of: Environment.production.webBaseURL.host!,
                    with: Environment.staging.webBaseURL.host!
                )
                .replacingOccurrences(
                    of: Environment.production.deepLinkUrl.host!,
                    with: Environment.staging.deepLinkUrl.host!
                )
        }

        self.question = question
        self.answer = answer
        self.relatedQuestions = relatedQuestions
    }
}
