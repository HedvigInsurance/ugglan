import Foundation
import hCore
import hGraphQL

public struct HelpCenterModel: Codable, Equatable, Hashable {
    let title: String
    let description: String
    let commonTopics: [CommonTopic]
    let commonQuestions: [Question]
}

public struct CommonTopic: Codable, Equatable, Hashable {
    let title: String
    let type: ChatTopicType?
    let commonQuestions: [Question]
    let allQuestions: [Question]
}

public struct Question: Codable, Equatable, Hashable {
    let question: String
    let answer: String
    let topicType: ChatTopicType?
    let relatedQuestions: [Question]

    public init(question: String, answer: String, topicType: ChatTopicType?, relatedQuestions: [Question] = []) {
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
        self.topicType = topicType
        self.relatedQuestions = relatedQuestions
    }
}
