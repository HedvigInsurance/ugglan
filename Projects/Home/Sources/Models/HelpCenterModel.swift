import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct HelpCenterModel: Codable, Equatable, Hashable, Sendable {
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
    let answer: String
    let relatedQuestions: [Question]

    public init(
        question: String,
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
            for deeplinkWithIndex in Environment.production.deepLinkUrls.enumerated() {
                let index = deeplinkWithIndex.offset
                answer = answer.replacingOccurrences(
                    of: deeplinkWithIndex.element.host!,
                    with: Environment.staging.deepLinkUrls[index].host!
                )
            }
        }
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
