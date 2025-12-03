import Foundation
@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelFetchNewMessages: XCTestCase {
    weak var sut: MockConversationService?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testFetchNewMessagesSuccess() async {
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
        assert(successMessages.count == 1)
        assert(successMessages.first?.type == messageType)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getNewMessages)
        sut = mockService
    }

    func testFetchNewMessagesFailure() async {
        let mockService = MockData.createMockChatService(fetchNewMessages: { throw ChatError.fetchMessagesFailed })
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.messages.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getNewMessages)
        sut = mockService
    }
}
