import Foundation
import hCore
import hGraphQL

public class SendMessagesClientOctopus: SendMessageClient {
    @Inject var octopus: hOctopus
    @Inject var chatFileUploaderClient: ChatFileUploaderClient
    public func send(message: String) async throws -> SentMessageWrapper {
        let data = try await octopus.client.perform(
            mutation: OctopusGraphQL.ChatSendTextMutation(input: .init(text: message))
        )
        if let error = data.chatSendText.error?.message {
            throw NetworkError.badRequest(message: error)
        }
        return .init(
            message: data.chatSendText.message?.fragments.messageFragment.asMessage(),
            status: data.chatSendText.status?.message
        )
    }

    public func send(for file: hCore.File) async throws -> SentMessageWrapper {
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
    }
}
