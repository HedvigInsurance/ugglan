import Foundation

public enum ChatTopicType: Codable, Equatable, Hashable {
    case payments
    case claims
    case coverage
    case myInsurance
}

public struct ChatTopicWrapper: Equatable, Identifiable {
    public let id: Int?
    public let topic: ChatTopicType?
    public let onTop: Bool

    public init(topic: ChatTopicType?, onTop: Bool) {
        self.id = topic?.hashValue ?? 1
        self.topic = topic
        self.onTop = onTop
    }
}
