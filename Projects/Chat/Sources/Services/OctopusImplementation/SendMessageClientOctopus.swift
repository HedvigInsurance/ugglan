import Foundation
import hCore
import hGraphQL

public class SendMessagesClientOctopus: SendMessageClient {
    @Inject var octopus: hOctopus
    @Inject var chatFileUploaderClient: ChatFileUploaderClient

    public init() {}

    public func send(message: Message) async throws -> SentMessageWrapper {
        switch message.type {
        case .text(let text):
            let data = try await octopus.client.perform(
                mutation: OctopusGraphQL.ChatSendTextMutation(input: .init(text: text))
            )
            if let error = data.chatSendText.error?.message {
                throw NetworkError.badRequest(message: error)
            }
            return .init(
                message: data.chatSendText.message?.fragments.messageFragment.asMessage(),
                status: data.chatSendText.status?.message
            )
        case .file(let file):
            let uploadResponse = try await chatFileUploaderClient.upload(files: [file]) { progress in

            }
            let token = uploadResponse.first?.uploadToken ?? ""
            let data = try await octopus.client.perform(
                mutation: OctopusGraphQL.ChatSendFileMutation(input: .init(uploadToken: token))
            )
            if let error = data.chatSendFile.error?.message {
                throw NetworkError.badRequest(message: error)
            }
            return .init(
                message: data.chatSendFile.message?.fragments.messageFragment.asMessage(),
                status: data.chatSendFile.status?.message
            )
        default:
            throw NetworkError.badRequest(message: nil)
        }
    }
}
