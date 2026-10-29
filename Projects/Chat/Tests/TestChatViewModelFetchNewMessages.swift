import Foundation
import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelFetchNewMessages {
        private weak var sut: MockConversationService?

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func fetchNewMessagesSuccess() async {
            do {
                let messageType = MessageType.text(text: "test", action: nil)
                let message = Message(type: messageType)
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: {
                        .init(with: [
                            .init(
                                id: message.id,
                                type: message.type,
                                sender: message.sender,
                                date: message.sentAt,
                                disclaimer: nil
                            )
                        ])
                    }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                let successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
                #expect(successMessages.count == 1)
                #expect(successMessages.first?.type == messageType)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getNewMessages)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func fetchNewMessagesFailure() async {
            do {
                let mockService = MockData.createMockChatService(fetchNewMessages: {
                    throw ChatError.fetchMessagesFailed
                })
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                #expect(model.messageVm.messages.isEmpty)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getNewMessages)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
