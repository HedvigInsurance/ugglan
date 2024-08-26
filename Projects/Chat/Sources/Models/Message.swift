import Foundation
import hCore
import hGraphQL

public struct Message: Identifiable, Codable, Hashable {
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

    private init(localId: String?, type: MessageType, date: Date, status: MessageStatus) {
        self.localId = localId
        self.remoteId = nil
        self.sender = .member
        self.type = type
        self.sentAt = date
        self.status = status
    }

    func asFailed(with error: String) -> Message {
        return Message(localId: UUID().uuidString, type: type, date: sentAt, status: .failed(error: error))
    }
}

enum MessageSender: Codable, Hashable {
    case member
    case hedvig
}

enum MessageStatus: Codable, Hashable {
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
enum MessageType: Codable, Hashable {
    case text(text: String)
    case file(file: File)
    case crossSell(url: URL)
    case deepLink(url: URL)
    case otherLink(url: URL)
    case unknown
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
            }
        }()
        return "\(senderText): \(message)"
    }
}
