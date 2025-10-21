import Chat
import Foundation
import PresentableStore
import hCore
import hGraphQL

class ConversationsClientOctopus: ConversationsClient {
    @Inject private var octopus: hOctopus

    func getConversations() async throws -> [Conversation] {
        let query = hGraphQL.OctopusGraphQL.ConversationsQuery()
        let data = try await octopus.client.fetchQuery(query: query)
        let conversationsFragment = data.currentMember.conversations.compactMap(\.fragments.conversationFragment)
        var conversations = conversationsFragment.compactMap { $0.asConversation(type: .service) }

        if let legacyFragment = data.currentMember.legacyConversation?.fragments.conversationFragment {
            let legacyConversation = legacyFragment.asConversation(type: .legacy)
            conversations.insert(legacyConversation, at: 0)
        }

        let conversationsSortedByDate = conversations.sorted(by: {
            if $0.hasNewMessage, !$1.hasNewMessage {
                return true
            } else if !$0.hasNewMessage, $1.hasNewMessage {
                return false
            } else if $0.isOpened, $1.isClosed {
                return true
            } else if $0.isClosed, $1.isOpened {
                return false
            }
            return $0.getAnyDate > $1.getAnyDate
        })
        return conversationsSortedByDate
    }

    func createConversation(with id: UUID) async throws -> Conversation {
        let input = OctopusGraphQL.ConversationStartInput(id: id.uuidString)
        let mutation = hGraphQL.OctopusGraphQL.ConversationStartMutation(input: input)
        let data = try await octopus.client.performMutation(mutation: mutation)!
        let conversationsFragment = data.conversationStart.fragments.conversationFragment

        return .init(fragment: conversationsFragment, type: .service)
    }
}

class ConversationClientOctopus: ConversationClient {
    @Inject var octopus: hOctopus
    var chatFileUploaderService = ChatFileUploaderService()

    func send(message: Message, for conversationId: String) async throws -> Message {
        var textToSend: String?
        var fileToken: String?
        switch message.type {
        case let .text(text):
            textToSend = text
        case let .file(file):
            do {
                let uploadResponse = try await chatFileUploaderService.upload(files: [file]) { _ in }
                fileToken = uploadResponse.first?.uploadToken ?? ""
            } catch _ {
                throw ConversationsError.uploadFailed
            }
        default:
            break
        }
        let input = OctopusGraphQL.ConversationSendMessageInput(
            id: conversationId,
            messageId: .init(optionalValue: message.id),
            text: .init(optionalValue: textToSend),
            fileUploadToken: .init(optionalValue: fileToken)
        )
        let mutation = hGraphQL.OctopusGraphQL.ConversationSendMessageMutation(input: input)
        let data = try await octopus.client.performMutation(mutation: mutation)!
        if let message = data.conversationSendMessage.message?.fragments.messageFragment {
            return message.asMessage()
        } else if let errorMessage = data.conversationSendMessage.userError?.message {
            throw ConversationsError.errorMesage(message: errorMessage)
        }
        throw ConversationsError.missingData
    }

    func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ConversationMessagesData {
        let query = hGraphQL.OctopusGraphQL.ConversationMessagesQuery(
            conversationId: conversationId,
            olderToken: .init(optionalValue: olderToken),
            newerToken: .init(optionalValue: newerToken)
        )

        guard
            let conversation = try await octopus.client.fetchQuery(query: query)
                .conversation
        else {
            throw ConversationsError.missingConversation
        }
        let messages = conversation.messagePage.messages.compactMap { $0.fragments.messageFragment.asMessage() }
        let newerToken = conversation.messagePage.newerToken
        let newOlderToken = conversation.messagePage.olderToken
        let banner = conversation.statusMessage
        let isConversationOpen = conversation.isOpen
        let hasClaim = conversation.claim != nil
        return .init(
            messages: messages,
            banner: banner,
            olderToken: newOlderToken,
            newerToken: newerToken,
            isConversationOpen: isConversationOpen,
            createdAt: conversation.createdAt,
            isLegacy: conversation.isLegacy,
            hasClaim: hasClaim,
            claimType: conversation.claim?.claimType,
            claimId: conversation.claim?.id
        )
    }
}

@MainActor
extension OctopusGraphQL.ConversationFragment {
    func asConversation(type: ConversationType) -> Conversation {
        .init(
            id: id,
            type: type,
            newestMessage: newestMessage?.fragments.messageFragment.asMessage(),
            createdAt: createdAt,
            statusMessage: statusMessage,
            status: isOpen ? .open : .closed,
            hasClaim: claim != nil,
            claimType: claim?.claimType,
            unreadMessageCount: unreadMessageCount
        )
    }
}

@MainActor
extension OctopusGraphQL.MessageFragment {
    func asMessage() -> Message {
        .init(
            id: id,
            type: messageType,
            sender: sender.asMessageSender,
            date: sentAt.localDateToIso8601Date ?? Date(),
            disclaimer: getDisclaimer
        )
    }

    private var getDisclaimer: MessageDisclaimer? {
        if let disclaimer {
            return .init(fragment: disclaimer.fragments.chatMessageDisclaimerFragment)
        }
        return nil
    }

    private var messageType: MessageType {
        if let action = asChatMessageAction {
            let urlText = action.actionUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            if let url = URL(string: urlText), urlText.isUrl {
                let data = ActionMessage(url: url, text: action.actionText, buttonTitle: action.actionTitle)
                return .action(action: data)
            }
        } else if let text = asChatMessageText?.text {
            let urlText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if let url = URL(string: urlText), urlText.isUrl {
                if urlText.isGIFURL {
                    return .file(
                        file: .init(
                            id: id,
                            size: 0,
                            mimeType: .GIF,
                            name: "",
                            source: .url(url: url, mimeType: .GIF)
                        )
                    )
                } else if urlText.isCrossSell {
                    return .crossSell(url: url)
                } else if urlText.isDeepLink {
                    return .deepLink(url: url)
                } else {
                    return .otherLink(url: url)
                }
            } else {
                return .text(text: encodeLinks(in: text))
            }
        } else if let file = asChatMessageFile {
            if let url = URL(string: file.signedUrl) {
                let mimeType = MimeType.findBy(mimeType: file.mimeType)
                return .file(
                    file: .init(
                        id: id,
                        size: 0,
                        mimeType: mimeType,
                        name: "",
                        source: .url(url: url, mimeType: mimeType)
                    )
                )
            } else {
                return .unknown
            }
        }
        return .unknown
    }

    // Encodes all URLs in the text so they are safe to use in Markdown links
    private func encodeLinks(in text: String) -> String {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))

            var result = text
            for match in matches.reversed() {
                guard let range = Range(match.range, in: text) else { continue }

                let urlText = String(text[range])
                let encodedURL = encodeURLForMarkdown(urlText)
                result.replaceSubrange(range, with: encodedURL)
            }

            return result
        } catch {
            return text  // Return original text if encoding fails
        }
    }

    private func encodeURLForMarkdown(_ urlString: String) -> String {
        var allowed = CharacterSet.urlFragmentAllowed
        allowed.remove(charactersIn: "_")  // force `_` to be encoded
        return urlString.addingPercentEncoding(withAllowedCharacters: allowed) ?? urlString
    }
}

extension GraphQLEnum<OctopusGraphQL.ChatMessageSender> {
    fileprivate var asMessageSender: MessageSender {
        switch self {
        case .case(let sender):
            switch sender {
            case .member:
                return .member
            case .hedvig:
                return .hedvig
            case .automation:
                return .automation
            }
        case .unknown:
            return .hedvig
        }
    }
}

extension Conversation {
    public init(
        fragment: OctopusGraphQL.ConversationFragment,
        type: ConversationType
    ) {
        let newestMessage: Message? = {
            if let newestMessage = fragment.newestMessage?.fragments.messageFragment.asMessage() {
                return .init(newestMessage)
            }
            return nil
        }()

        self.init(
            id: fragment.id,
            type: type,
            newestMessage: newestMessage,
            createdAt: fragment.createdAt,
            statusMessage: fragment.statusMessage,
            status: fragment.isOpen ? .open : .closed,
            hasClaim: fragment.claim != nil,
            claimType: fragment.claim?.claimType,
            unreadMessageCount: fragment.unreadMessageCount
        )
    }
}

extension MessageDisclaimer {
    init(
        fragment: OctopusGraphQL.ChatMessageDisclaimerFragment,
    ) {
        self.init(
            description: fragment.description,
            detailsDescription: fragment.detailsDescription,
            detailsTitle: fragment.detailsTitle,
            title: fragment.title,
            type: fragment.type == .escalation ? .escalation : .information
        )
    }
}
