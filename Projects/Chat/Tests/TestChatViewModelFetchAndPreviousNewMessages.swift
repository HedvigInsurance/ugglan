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
        let message = Message(type: .text(text: "testMessage", action: nil))
        let newMessages = [
            Message(id: message.id, type: message.type, sender: message.sender, date: message.sentAt, disclaimer: nil)
        ]

        let previousMessage = Message(type: .text(text: "testMessage", action: nil))
        let previousMessages = [
            Message(
                id: previousMessage.id,
                type: previousMessage.type,
                sender: previousMessage.sender,
                date: previousMessage.sentAt,
                disclaimer: nil
            )
        ]

        let mockService = MockData.createMockChatService(
            fetchNewMessages: {
                .init(with: newMessages, hasPreviousMessages: true)
            },
            fetchPreviousMessages: { .init(with: previousMessages) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        var successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
        assert(successMessages.count == newMessages.count)
        await model.messageVm.fetchPreviousMessages(retry: false)
        successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
        assert(successMessages.count == newMessages.count + previousMessages.count)
        sut = mockService
    }

    func testFetchNewAndPreviousMessagesWithHasPreviousMessageFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed },
            fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.messages.isEmpty)
        await model.messageVm.fetchPreviousMessages(retry: false)
        assert(model.messageVm.messages.isEmpty)
        sut = mockService
    }
}
