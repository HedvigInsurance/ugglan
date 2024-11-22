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
        let messageType = MessageType.text(text: "test")
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(with: [.init(type: messageType)]) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messages.count == 1)
        assert(model.messages.first?.type == messageType)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getNewMessages)
        self.sut = mockService
    }

    func testFetchNewMessagesFailure() async {
        let mockService = MockData.createMockChatService(fetchNewMessages: { throw ChatError.fetchMessagesFailed })
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messages.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getNewMessages)
        self.sut = mockService
    }
}
