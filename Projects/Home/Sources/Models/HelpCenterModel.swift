import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct HelpCenterModel: Codable, Equatable, Hashable, Sendable {
    let title: String
    let description: String
    let commonTopics: [CommonTopic]
    let commonQuestions: [Question]
}

public struct CommonTopic: Codable, Equatable, Hashable, Sendable {
    let title: String
    let commonQuestions: [Question]
    let allQuestions: [Question]
}

public struct Question: Codable, Equatable, Hashable, Sendable {
    let question: String
    let questionEn: String
    let answer: String
    let relatedQuestions: [Question]

    public init(
        question: String,
        questionEn: String,
        answer: String,
        relatedQuestions: [Question] = []
    ) {
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
        self.questionEn = questionEn
        self.question = question
        self.answer = answer
        self.relatedQuestions = relatedQuestions
    }
}

extension Question: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: HelpCenterQuestionView.self)
    }
}

extension CommonTopic: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: HelpCenterTopicView.self)
    }
}
