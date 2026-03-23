public struct Partner: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let imageUrl: String?
    public let url: String?
    public let phoneNumber: String?
    public let title: String?
    public let description: String?
    public let info: String?
    public let buttonText: String?
    public let preferredImageHeight: Int?

    public init(
        id: String,
        imageUrl: String?,
        url: String?,
        phoneNumber: String?,
        title: String?,
        description: String?,
        info: String?,
        buttonText: String?,
        preferredImageHeight: Int?
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.url = url
        self.phoneNumber = phoneNumber
        self.title = title
        self.description = description
        self.info = info
        self.buttonText = buttonText
        self.preferredImageHeight = preferredImageHeight
    }
}

public struct LinkOnlyPartner: Codable, Equatable, Hashable, Sendable {
    public let url: String
    public let buttonText: String

    public init(url: String, buttonText: String) {
        self.url = url
        self.buttonText = buttonText
    }
}

public struct DeflectQuestion: Sendable, Hashable {
    public let question: String
    public let answer: String

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}
