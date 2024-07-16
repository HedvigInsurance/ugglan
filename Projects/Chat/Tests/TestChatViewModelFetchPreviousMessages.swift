import Foundation
import XCTest

@testable import Chat

final class TestChatViewModelFetchPreviousMessages: XCTestCase {

    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        XCTAssertNil(sut)
    }

    func testFetchPreviousMessagesSuccess() async {
        let messageType = MessageType.text(text: "test")
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
            fetchPreviousMessages: { .init(with: [.init(type: messageType)], hasPreviousMessages: false) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        await model.fetchPreviousMessages()
        assert(model.messages.count == 1)
        assert(model.messages.first?.type == messageType)
        assert(mockService.events.count == 2)
        assert(mockService.events.first == .getNewMessages)
        assert(mockService.events.last == .getPreviousMessages)
        self.sut = mockService
    }

    func testFetchPreviousMessagesFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
            fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        await model.fetchPreviousMessages()
        assert(model.messages.count == 0)
        assert(mockService.events.count == 2)
        assert(mockService.events.first == .getNewMessages)
        assert(mockService.events.last == .getPreviousMessages)
        self.sut = mockService
    }

}
