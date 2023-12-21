import Foundation
import hCore

public struct HelpCenterModel: Codable, Equatable, Hashable {
    let title: String
    let description: String
    let quickActions: [QuickAction]
    let commonTopics: [CommonTopic]
    let commonQuestions: [Question]
}

struct QuickAction: Codable, Equatable, Hashable {
    let title: String
    let deepLink: DeepLink
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
}
