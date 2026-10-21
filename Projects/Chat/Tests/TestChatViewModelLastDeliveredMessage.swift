import Foundation
import TestDependencies
import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelLastDeliveredMessage {
        private weak var sut: MockConversationService?
        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func sendNewMessageSuccess() async {
            await recordingErrors {
                let messageType = MessageType.text(text: "test", action: nil)
                let message = Message(type: messageType)
                let mockService = MockData.createMockChatService(
                    sendMessage: { message in message }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.send(message: message)
                try await Task.sleep(for: .seconds(0.2))
                #expect(model.messageVm.lastDeliveredMessage == message)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func sendNewMessageFailure() async {
            do {
                let messageType = MessageType.text(text: "test", action: nil)
                let message = Message(type: messageType)
                let mockService = MockData.createMockChatService(
                    sendMessage: { _ in throw ChatError.sendMessageFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.send(message: message)
                #expect(model.messageVm.lastDeliveredMessage == nil)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func sendMultipleMessagesSuccess() async {
            await recordingErrors {
                let messageType = MessageType.text(text: "test", action: nil)
                let message = Message(type: messageType)
                let mockService = MockData.createMockChatService(
                    sendMessage: { message in message }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.send(message: message)
                try await Task.sleep(for: .seconds(0.2))
                #expect(model.messageVm.lastDeliveredMessage == message)
                let newMessage = Message(type: messageType)
                await model.messageVm.send(message: newMessage)
                try await Task.sleep(for: .seconds(0.2))
                #expect(model.messageVm.lastDeliveredMessage == newMessage)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func sendMultipleMessagesFailure() async {
            await recordingErrors {
                let messageType = MessageType.text(text: "test", action: nil)
                let firstMessage = Message(type: messageType)
                let mockService = MockData.createMockChatService(
                    sendMessage: { message in message }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.send(message: firstMessage)
                try await Task.sleep(for: .seconds(0.2))
                #expect(model.messageVm.lastDeliveredMessage == firstMessage)

                mockService.sendMessage = { _ in throw ChatError.sendMessageFailed }
                let newMessage = Message(type: messageType)
                await model.messageVm.send(message: newMessage)
                #expect(model.messageVm.lastDeliveredMessage == firstMessage)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
