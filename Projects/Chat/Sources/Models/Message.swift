import Foundation
import hCore

public struct Message: Codable, Identifiable, Hashable, Sendable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String
    let sender: MessageSender
    public let sentAt: Date
    public let type: MessageType
    public let disclaimer: MessageDisclaimer?
    var status: MessageStatus

    init(
        id: String,
        sender: MessageSender,
        sentAt: Date,
        type: MessageType,
        disclaimer: MessageDisclaimer?,
        status: MessageStatus
    ) {
        self.id = id
        self.sender = sender
        self.sentAt = sentAt
        self.type = type
        self.disclaimer = disclaimer
        self.status = status
    }

    public init(type: MessageType) {
        id = UUID().uuidString
        sender = .member
        self.type = type
        sentAt = Date()
        self.disclaimer = nil
        status = .draft
    }

    public init(id: String, type: MessageType, date: Date) {
        self.id = id
        sender = .member
        self.type = type
        sentAt = date
        self.disclaimer = nil
        status = .sent
    }

    public init(id: String, type: MessageType, sender: MessageSender, date: Date, disclaimer: MessageDisclaimer?) {
        self.id = id
        self.sender = sender
        self.type = type
        sentAt = date
        self.disclaimer = disclaimer
        status = sender == .hedvig ? .received : .sent
    }

    private init(id: String, type: MessageType, date: Date, status: MessageStatus) {
        self.id = id
        sender = .member
        self.type = type
        sentAt = date
        self.status = status
        self.disclaimer = nil
    }

    func asFailed(with error: String) -> Message {
        Message(id: UUID().uuidString, type: type, date: sentAt, status: .failed(error: error))
    }

    func copyWith(type: MessageType) -> Message {
        Message(id: id, sender: sender, sentAt: sentAt, type: type, disclaimer: disclaimer, status: status)
    }

    var trimmedText: String {
        switch type {
        case let .text(text):
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        default:
            return ""
        }
    }
}

public enum MessageSender: Codable, Hashable, Sendable {
    case member
    case hedvig
    case automation
}

enum MessageStatus: Codable, Hashable, Sendable {
    case draft
    case sent
    case received
    case failed(error: String)

    private var valueToAdd: String {
        switch self {
        case .draft: return "draft"
        case .sent: return "sent"
        case .received: return "received"
        case let .failed(error): return "failed\(error)"
        }
    }
}

public enum MessageType: Codable, Hashable, Sendable {
    case text(text: String)
    case file(file: File)
    case crossSell(url: URL)
    case deepLink(url: URL)
    case otherLink(url: URL)
    case action(action: ActionMessage)
    case unknown
}

public struct ActionMessage: Codable, Hashable, Sendable {
    let url: URL
    let text: String?
    let buttonTitle: String

    public init(url: URL, text: String?, buttonTitle: String) {
        self.url = url
        self.text = text
        self.buttonTitle = buttonTitle
    }
}

public struct MessageDisclaimer: Codable, Hashable, Sendable {
    let description: String?
    let detailsDescription: String?
    let detailsTitle: String?
    let title: String?
    let type: ChatMessageDisclaimerType

    public init(
        description: String?,
        detailsDescription: String?,
        detailsTitle: String?,
        title: String?,
        type: ChatMessageDisclaimerType
    ) {
        self.description = description
        self.detailsDescription = detailsDescription
        self.detailsTitle = detailsTitle
        self.title = title
        self.type = type
    }
}

public enum ChatMessageDisclaimerType: Codable, Sendable {
    case information
    case escalation
}

extension Sequence where Iterator.Element == Message {
    func filterNotAddedIn(list alreadyAdded: [String]) -> [Message] {
        filter { !alreadyAdded.contains($0.id) }
    }
}

extension Message {
    var latestMessageText: String {
        let senderText: String = {
            switch sender {
            case .member: return L10n.chatSenderMember
            case .hedvig: return L10n.chatSenderHedvig
            case .automation: return L10n.chatSenderAutomation
            }
        }()
        let message: String = {
            switch type {
            case let .text(text):
                return text
            case let .file(file):
                if file.mimeType.isImage {
                    return L10n.chatSentAPhoto
                }
                return L10n.chatSentAFile
            case .crossSell:
                return L10n.chatSentALink
            case .deepLink:
                return L10n.chatSentALink
            case .otherLink:
                return L10n.chatSentALink
            case .unknown:
                return L10n.chatSentAMessage
            case .action:
                return L10n.chatSentALink
            }
        }()
        return "\(senderText): \(message)"
    }
}
