import Foundation
@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelLastDeliveredMessage: XCTestCase {
    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testSendNewMessageSuccess() async throws {
        let messageType = MessageType.text(text: "test")
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { message in message }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.send(message: message)
        try await Task.sleep(seconds: 0.2)
        assert(model.messageVm.lastDeliveredMessage == message)
        sut = mockService
    }

    func testSendNewMessageFailure() async {
        let messageType = MessageType.text(text: "test")
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { _ in throw ChatError.sendMessageFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.send(message: message)
        assert(model.messageVm.lastDeliveredMessage == nil)
        sut = mockService
    }

    func testSendMultipleMessagesSuccess() async throws {
        let messageType = MessageType.text(text: "test")
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { message in message }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.send(message: message)
        try await Task.sleep(seconds: 0.2)
        assert(model.messageVm.lastDeliveredMessage == message)
        let newMessage = Message(type: messageType)
        await model.messageVm.send(message: newMessage)
        try await Task.sleep(seconds: 0.2)
        assert(model.messageVm.lastDeliveredMessage == newMessage)
        sut = mockService
    }

    func testSendMultipleMessagesFailure() async throws {
        let messageType = MessageType.text(text: "test")
        let firstMessage = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { message in message }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.send(message: firstMessage)
        try await Task.sleep(seconds: 0.2)
        assert(model.messageVm.lastDeliveredMessage == firstMessage)

        mockService.sendMessage = { _ in throw ChatError.sendMessageFailed }
        let newMessage = Message(type: messageType)
        await model.messageVm.send(message: newMessage)
        assert(model.messageVm.lastDeliveredMessage == firstMessage)
        sut = mockService
    }
}
