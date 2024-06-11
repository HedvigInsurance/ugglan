import Foundation
import hCore
import hGraphQL

public class SendMessagesService {
    @Inject var service: SendMessageClient

    public func send(message: Message, topic: ChatTopicType?) async throws -> Message {
        log.info("SendMessagesService: send", error: nil, attributes: nil)
        return try await service.send(message: message, topic: topic)
    }
}

public class SendMessagesClientOctopus: SendMessageClient {
    @Inject var octopus: hOctopus
    var chatFileUploaderService = ChatFileUploaderService()

    public init() {}

    public func send(message: Message, topic: ChatTopicType?) async throws -> Message {
        switch message.type {
        case .text(let text):
            let data = try await octopus.client.perform(
                mutation: OctopusGraphQL.ChatSendTextMutation(
                    input: .init(text: text, context: GraphQLNullable(optionalValue: topic?.asChatMessageContext))
                )
            )
            if let error = data.chatSendText.error?.message {
                throw SendMessageError.errorMesage(message: error)
            }
            if let message = data.chatSendText.message?.fragments.messageFragment.asMessage() {
                return message
            }

            throw SendMessageError.missingData

        case .file(let file):
            let uploadResponse = try await chatFileUploaderService.upload(files: [file]) { progress in

            }
            let token = uploadResponse.first?.uploadToken ?? ""
            let data = try await octopus.client.perform(
                mutation: OctopusGraphQL.ChatSendFileMutation(
                    input: .init(
                        uploadToken: token,
                        context: GraphQLNullable(optionalValue: topic?.asChatMessageContext)
                    )
                )
            )
            if let error = data.chatSendFile.error?.message {
                throw SendMessageError.errorMesage(message: error)
            }
            if let message = data.chatSendFile.message?.fragments.messageFragment.asMessage() {
                return message
            }

            throw SendMessageError.missingData
        default:
            throw NetworkError.badRequest(message: nil)
        }
    }
}

extension ChatTopicType {
    fileprivate var asChatMessageContext: GraphQLEnum<OctopusGraphQL.ChatMessageContext> {
        switch self {
        case .payments:
            return GraphQLEnum<OctopusGraphQL.ChatMessageContext>(.helpCenterPayments)
        case .claims:
            return GraphQLEnum<OctopusGraphQL.ChatMessageContext>(.helpCenterClaims)
        case .coverage:
            return GraphQLEnum<OctopusGraphQL.ChatMessageContext>(.helpCenterCoverage)
        case .myInsurance:
            return GraphQLEnum<OctopusGraphQL.ChatMessageContext>(.helpCenterMyInsurance)
        }
    }
}

enum SendMessageError: Error {
    case errorMesage(message: String)
    case missingData
}

extension SendMessageError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .errorMesage(message): return message
        case .missingData: return "TODO"
        }
    }
}
