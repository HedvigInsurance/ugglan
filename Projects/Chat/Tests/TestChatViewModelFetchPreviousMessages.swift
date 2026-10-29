import Foundation
import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelFetchPreviousMessages {
        private weak var sut: MockConversationService?
        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func fetchPreviousMessagesSuccess() async {
            do {
                let messageType = MessageType.text(text: "test", action: nil)
                let message = Message(type: messageType)
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
                    fetchPreviousMessages: {
                        .init(
                            with: [
                                Message(
                                    id: message.id,
                                    type: message.type,
                                    sender: message.sender,
                                    date: message.sentAt,
                                    disclaimer: nil
                                )
                            ],
                            hasPreviousMessages: false
                        )
                    }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                await model.messageVm.fetchPreviousMessages(retry: false)
                let successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
                #expect(successMessages.count == 1)
                #expect(successMessages.first?.type == messageType)
                #expect(mockService.events.count == 2)
                #expect(mockService.events.first == .getNewMessages)
                #expect(mockService.events.last == .getPreviousMessages)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func fetchPreviousMessagesFailure() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
                    fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                await model.messageVm.fetchPreviousMessages(retry: false)
                let successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
                #expect(successMessages.count == 0)
                #expect(mockService.events.count == 2)
                #expect(mockService.events.first == .getNewMessages)
                #expect(mockService.events.last == .getPreviousMessages)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func fetchPreviousMessagesWithInitialFailureSuccess() async {
            do {
                let messageType = MessageType.text(text: "test", action: nil)
                let message = Message(type: messageType)
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
                    fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    mockService.fetchPreviousMessages = {
                        .init(
                            with: [
                                Message(
                                    id: message.id,
                                    type: message.type,
                                    sender: message.sender,
                                    date: message.sentAt,
                                    disclaimer: nil
                                )
                            ],
                            hasPreviousMessages: false
                        )
                    }
                }
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                await model.messageVm.fetchPreviousMessages(retry: true)

                let successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
                #expect(successMessages.count == 1)
                #expect(successMessages.first?.type == messageType)
                #expect(mockService.events.count == 3)
                #expect(mockService.events.first == .getNewMessages)
                #expect(mockService.events.last == .getPreviousMessages)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
