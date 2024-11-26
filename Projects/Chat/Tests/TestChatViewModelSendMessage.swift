import Foundation
@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelSendMessage: XCTestCase {
    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        assert(sut == nil)
    }

    func testSendNewMessageSuccess() async {
        let messageType = MessageType.text(text: "test")
        let mockService = MockData.createMockChatService(
            sendMessage: { message in message }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.send(message: .init(type: messageType))
        assert(model.messages.count == 1)
        assert(model.messages.first?.type == messageType)
        assert(model.messages.first?.status == .sent)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .sendMessage)
        self.sut = mockService
    }

    func testSendNewMessageFailure() async {
        let messageType = MessageType.text(text: "test")
        let mockService = MockData.createMockChatService(
            sendMessage: { message in throw ChatError.sendMessageFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.send(message: .init(type: messageType))
        assert(model.messages.count == 1)
        assert(
            model.messages.first?.status
                == Message(type: messageType).asFailed(with: ChatError.sendMessageFailed.localizedDescription).status
        )
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .sendMessage)
        self.sut = mockService
    }

}
