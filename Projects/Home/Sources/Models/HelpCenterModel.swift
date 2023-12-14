import Foundation
import hCore

public struct HelpCenterModel {
    let title: String
    let description: String
    let quickActions: [QuickAction]
    let commonTopics: [CommonTopic]
    let commonQuestions: [Question]
}

struct QuickAction: Hashable {
    let title: String
    let deepLink: DeepLink
}

struct CommonTopic: Hashable {
    let title: String
    let commonQuestions: [Question]
    let allQuestions: [Question]
}

struct Question: Hashable {
    let question: String
    let answer: String
}
