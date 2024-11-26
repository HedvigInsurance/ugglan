import Foundation
@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelFetchAndPreviousNewMessages: XCTestCase {

    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testFetchNewAndPreviousMessagesWithHasPreviousMessageSuccess() async {
        let newMessages = [Message(type: .text(text: "testMessage"))]
        let previousMessages = [Message(type: .text(text: "testMessage"))]

        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(with: newMessages, hasPreviousMessages: true) },
            fetchPreviousMessages: { .init(with: previousMessages) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messages.count == newMessages.count)
        await model.fetchPreviousMessages(retry: false)
        assert(model.messages.count == newMessages.count + previousMessages.count)
        self.sut = mockService
    }

    func testFetchNewAndPreviousMessagesWithHasPreviousMessageFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed },
            fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messages.isEmpty)
        await model.fetchPreviousMessages(retry: false)
        assert(model.messages.isEmpty)
        self.sut = mockService
    }
}
