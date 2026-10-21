import Foundation
import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelSendMessage {
        private weak var sut: MockConversationService?
        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func sendNewMessageSuccess() async {
            do {
                let messageType = MessageType.text(text: "test", action: nil)
                let mockService = MockData.createMockChatService(
                    sendMessage: { message in message }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.send(message: .init(type: messageType))
                #expect(model.messageVm.messages.count == 1)
                #expect(model.messageVm.messages.first?.type == messageType)
                #expect(model.messageVm.messages.first?.status == .sent)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .sendMessage)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func sendNewMessageFailure() async {
            do {
                let messageType = MessageType.text(text: "test", action: nil)
                let mockService = MockData.createMockChatService(
                    sendMessage: { _ in throw ChatError.sendMessageFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.send(message: .init(type: messageType))
                #expect(model.messageVm.messages.count == 1)
                #expect(
                    model.messageVm.messages.first?.status
                        == Message(type: messageType).asFailed(with: ChatError.sendMessageFailed.localizedDescription)
                        .status
                )
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .sendMessage)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
