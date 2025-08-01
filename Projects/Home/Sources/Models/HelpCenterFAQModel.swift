import Environment
import Foundation
import hCore
import hCoreUI

public struct HelpCenterFAQModel: Codable, Equatable, Hashable, Sendable {
    public let topics: [FaqTopic]
    let commonQuestions: [FAQModel]

    public init(topics: [FaqTopic], commonQuestions: [FAQModel]) {
        self.topics = topics
        self.commonQuestions = commonQuestions
    }
}

public struct FaqTopic: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    let title: String
    let commonQuestions: [FAQModel]
    let allQuestions: [FAQModel]

    public init(id: String, title: String, commonQuestions: [FAQModel], allQuestions: [FAQModel]) {
        self.id = id
        self.title = title
        self.commonQuestions = commonQuestions
        self.allQuestions = allQuestions
    }
}

public struct FAQModel: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    let question: String
    let answer: String
    let relatedQuestions: [FAQModel]

    public init(
        id: String,
        question: String,
        answer: String,
        relatedQuestions: [FAQModel] = []
    ) {
        self.id = id
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

extension FAQModel: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: HelpCenterQuestionView.self)
    }
}

extension FaqTopic: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: HelpCenterTopicView.self)
    }
}
