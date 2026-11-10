import AutomaticLog
import Foundation
import hCore

public struct Message: Codable, Identifiable, Hashable, Sendable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String
    public let sender: MessageSender
    public let sentAt: Date
    public let type: MessageType
    public let disclaimer: MessageDisclaimer?
    public var status: MessageStatus

    public init(
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

        switch sender {
        case .member:
            status = .sent
        case .hedvig:
            status = .received
        case .automation:
            status = .received
        }
    }

    private init(id: String, type: MessageType, date: Date, status: MessageStatus) {
        self.id = id
        sender = .member
        self.type = type
        sentAt = date
        self.status = status
        self.disclaimer = nil
    }

    public func asFailed(with error: String) -> Message {
        Message(id: UUID().uuidString, type: type, date: sentAt, status: .failed(error: error))
    }

    public func copyWith(type: MessageType) -> Message {
        Message(id: id, sender: sender, sentAt: sentAt, type: type, disclaimer: disclaimer, status: status)
    }

    public var trimmedText: String {
        switch type {
        case let .text(text, _):
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

public enum MessageStatus: Codable, Hashable, Sendable {
    case draft
    case sent
    case received
    case failed(error: String)
}

public enum MessageType: Codable, Hashable, Sendable {
    case text(text: String, action: ActionMessage?)
    case file(file: File)
    case crossSell(url: URL)
    case deepLink(url: URL)
    case otherLink(url: URL)
    case unknown
}

extension MessageType: MaskedValue {
    /// An associated value cannot carry `@Masked`, so the masking is written out here:
    /// member-written chat content never reaches the log, while the case itself stays readable.
    public var maskedDescription: String {
        switch self {
        case let .text(text, action):
            return "text(text: \(AutomaticLog.maskedLogDescription(text)), "
                + "action: \(AutomaticLog.logDescription(action as Any)))"
        case let .file(file):
            return "file(file: \(AutomaticLog.logDescription(file)))"
        case let .crossSell(url):
            return "crossSell(url: \(url))"
        case let .deepLink(url):
            return "deepLink(url: \(url))"
        case let .otherLink(url):
            return "otherLink(url: \(url))"
        case .unknown:
            return "unknown"
        }
    }
}

public struct ActionMessage: Codable, Hashable, Sendable {
    public let url: URL
    public let text: String?
    public let buttonTitle: String

    public init(url: URL, text: String?, buttonTitle: String) {
        self.url = url
        self.text = text
        self.buttonTitle = buttonTitle
    }
}

public struct MessageDisclaimer: Codable, Hashable, Sendable {
    public let description: String?
    public let detailsDescription: String?
    public let detailsTitle: String?
    public let title: String?
    public let type: ChatMessageDisclaimerType

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
    public func filterNotAddedIn(list alreadyAdded: [String]) -> [Message] {
        filter { !alreadyAdded.contains($0.id) }
    }
}

extension Message {
    public var latestMessageText: String {
        let senderText: String = {
            switch sender {
            case .member: return L10n.chatSenderMember
            case .hedvig: return L10n.chatSenderHedvig
            case .automation: return L10n.chatSenderAutomation
            }
        }()
        let message: String = {
            switch type {
            case let .text(text, _):
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
            }
        }()
        return "\(senderText): \(message)"
    }
}
