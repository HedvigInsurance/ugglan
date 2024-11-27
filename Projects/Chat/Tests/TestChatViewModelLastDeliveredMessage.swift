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

    func testSendNewMessageSuccess() async {
        let messageType = MessageType.text(text: "test")
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { message in message }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.send(message: message)
        assert(model.lastDeliveredMessage == message)
        self.sut = mockService
    }

    func testSendNewMessageFailure() async {
        let messageType = MessageType.text(text: "test")
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { message in throw ChatError.sendMessageFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.send(message: message)
        assert(model.lastDeliveredMessage == nil)
        self.sut = mockService
    }

    func testSendMultipleMessagesSuccess() async {
        let messageType = MessageType.text(text: "test")
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { message in message }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.send(message: message)
        assert(model.lastDeliveredMessage == message)
        let newMessage = Message(type: messageType)
        await model.send(message: newMessage)
        assert(model.lastDeliveredMessage == newMessage)
        self.sut = mockService
    }

    func testSendMultipleMessagesFailure() async {
        let messageType = MessageType.text(text: "test")
        let firstMessage = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            sendMessage: { message in message }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.send(message: firstMessage)
        assert(model.lastDeliveredMessage == firstMessage)

        mockService.sendMessage = { message in throw ChatError.sendMessageFailed }
        let newMessage = Message(type: messageType)
        await model.send(message: newMessage)
        assert(model.lastDeliveredMessage == firstMessage)
        self.sut = mockService
    }

}
