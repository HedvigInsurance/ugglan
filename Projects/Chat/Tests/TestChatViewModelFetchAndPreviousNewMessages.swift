import Foundation
import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelFetchAndPreviousNewMessages {
        private weak var sut: MockConversationService?
        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func fetchNewAndPreviousMessagesWithHasPreviousMessageSuccess() async {
            do {
                let message = Message(type: .text(text: "testMessage", action: nil))
                let newMessages = [
                    Message(
                        id: message.id,
                        type: message.type,
                        sender: message.sender,
                        date: message.sentAt,
                        disclaimer: nil
                    )
                ]

                let previousMessage = Message(type: .text(text: "testMessage", action: nil))
                let previousMessages = [
                    Message(
                        id: previousMessage.id,
                        type: previousMessage.type,
                        sender: previousMessage.sender,
                        date: previousMessage.sentAt,
                        disclaimer: nil
                    )
                ]

                let mockService = MockData.createMockChatService(
                    fetchNewMessages: {
                        .init(with: newMessages, hasPreviousMessages: true)
                    },
                    fetchPreviousMessages: { .init(with: previousMessages) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                var successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
                #expect(successMessages.count == newMessages.count)
                await model.messageVm.fetchPreviousMessages(retry: false)
                successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
                #expect(successMessages.count == newMessages.count + previousMessages.count)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func fetchNewAndPreviousMessagesWithHasPreviousMessageFailure() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { throw ChatError.fetchMessagesFailed },
                    fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                #expect(model.messageVm.messages.isEmpty)
                await model.messageVm.fetchPreviousMessages(retry: false)
                #expect(model.messageVm.messages.isEmpty)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
