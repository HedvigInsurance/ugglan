import Foundation
import hCore

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
            return "Change bank"
        case .updateAddress:
            return "Update address"
        case .editCoInsured:
            return "Edit co-insured"
        case .travelCertificate:
            return "Travel certificate"
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
}
