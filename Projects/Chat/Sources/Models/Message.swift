import Foundation
import hCore
import hGraphQL

public struct Message: Codable, Identifiable, Hashable, Sendable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.localId == rhs.localId || lhs.remoteId == rhs.remoteId
    }

    let localId: String?
    let remoteId: String?
    public var id: String {
        return remoteId ?? localId ?? ""
    }
    let sender: MessageSender
    public let sentAt: Date
    let type: MessageType
    var status: MessageStatus

    init(
        localId: String?,
        remoteId: String?,
        sender: MessageSender,
        sentAt: Date,
        type: MessageType,
        status: MessageStatus
    ) {
        self.localId = localId
        self.remoteId = remoteId
        self.sender = sender
        self.sentAt = sentAt
        self.type = type
        self.status = status
    }

    init(type: MessageType) {
        self.localId = UUID().uuidString
        self.remoteId = nil
        self.sender = .member
        self.type = type
        self.sentAt = Date()
        self.status = .draft
    }

    init(localId: String, remoteId: String, type: MessageType, date: Date) {
        self.localId = localId
        self.remoteId = remoteId
        self.sender = .member
        self.type = type
        self.sentAt = date
        self.status = .sent
    }

    init(remoteId: String, type: MessageType, sender: MessageSender, date: Date) {
        self.localId = nil
        self.remoteId = remoteId
        self.sender = sender
        self.type = type
        self.sentAt = date
        self.status = sender == .hedvig ? .received : .sent
    }

    private init(localId: String?, type: MessageType, date: Date, status: MessageStatus, sender: MessageSender?) {
        self.localId = localId
        self.remoteId = nil
        self.sender = sender ?? .member
        self.type = type
        self.sentAt = date
        self.status = status
    }

    func asFailed(with error: String, sender: MessageSender?) -> Message {
        return Message(
            localId: UUID().uuidString,
            type: type,
            date: sentAt,
            status: .failed(error: error),
            sender: sender
        )
    }

    func copyWith(type: MessageType) -> Message {
        return Message(localId: localId, remoteId: remoteId, sender: sender, sentAt: sentAt, type: type, status: status)
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

enum MessageSender: Codable, Hashable, Sendable {
    case member
    case hedvig
    case automatic
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
        case .failed(let error): return "failed\(error)"
        }
    }
}
enum MessageType: Codable, Hashable, Sendable {
    case text(text: String)
    case file(file: File)
    case crossSell(url: URL)
    case deepLink(url: URL)
    case otherLink(url: URL)
    case action(action: ActionMessage)
    case automaticSuggestions(suggestions: AutomaticSuggestions)
    case unknown
}

struct AutomaticSuggestions: Codable, Hashable {
    let suggestions: [ActionMessage?]
    let escalationReference: String?
}

struct ActionMessage: Codable, Hashable {
    let url: URL?
    let text: String?
    let buttonTitle: String
}

extension Sequence where Iterator.Element == Message {
    func filterNotAddedIn(list alreadyAdded: [String]) -> [Message] {
        return self.filter({ !alreadyAdded.contains($0.id) })
    }
}

extension Message {
    var latestMessageText: String {
        let senderText: String = {
            switch sender {
            case .member: return L10n.chatSenderMember
            case .hedvig: return L10n.chatSenderHedvig
            case .automatic: return "automatic"
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
            case let .automaticSuggestions(suggestions):
                return "automatic"
            }
        }()
        return "\(senderText): \(message)"
    }
}
