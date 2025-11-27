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

public struct FlowClaimDeflectConfig {
    public let infoText: String
    public let infoSectionText: String
    public let infoSectionTitle: String
    public let cardTitle: String?
    public let cardText: String
    public let buttonText: String?
    public let infoViewTitle: String?
    public let infoViewText: String?
    public let questions: [DeflectQuestion]

    public init(
        infoText: String,
        infoSectionText: String,
        infoSectionTitle: String,
        cardTitle: String?,
        cardText: String,
        buttonText: String?,
        infoViewTitle: String?,
        infoViewText: String?,
        questions: [DeflectQuestion]
    ) {
        self.infoText = infoText
        self.infoSectionText = infoSectionText
        self.infoSectionTitle = infoSectionTitle
        self.cardTitle = cardTitle
        self.cardText = cardText
        self.buttonText = buttonText
        self.infoViewTitle = infoViewTitle
        self.infoViewText = infoViewText
        self.questions = questions
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
