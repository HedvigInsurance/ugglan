import Foundation
@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelFetchPreviousMessages: XCTestCase {
    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testFetchPreviousMessagesSuccess() async {
        let messageType = MessageType.text(text: "test", action: nil)
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
            fetchPreviousMessages: {
                .init(
                    with: [
                        Message(
                            id: message.id,
                            type: message.type,
                            sender: message.sender,
                            date: message.sentAt,
                            disclaimer: nil
                        )
                    ],
                    hasPreviousMessages: false
                )
            }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        await model.messageVm.fetchPreviousMessages(retry: false)
        let successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
        assert(successMessages.count == 1)
        assert(successMessages.first?.type == messageType)
        assert(mockService.events.count == 2)
        assert(mockService.events.first == .getNewMessages)
        assert(mockService.events.last == .getPreviousMessages)
        sut = mockService
    }

    func testFetchPreviousMessagesFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
            fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        await model.messageVm.fetchPreviousMessages(retry: false)
        let successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
        assert(successMessages.count == 0)
        assert(mockService.events.count == 2)
        assert(mockService.events.first == .getNewMessages)
        assert(mockService.events.last == .getPreviousMessages)
        sut = mockService
    }

    func testFetchPreviousMessagesWithInitialFailureSuccess() async {
        let messageType = MessageType.text(text: "test", action: nil)
        let message = Message(type: messageType)
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(with: [], hasPreviousMessages: true) },
            fetchPreviousMessages: { throw ChatError.fetchPreviousMessagesFailed }
        )

        // update fetchPreviousMessages to return messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            mockService.fetchPreviousMessages = {
                .init(
                    with: [
                        Message(
                            id: message.id,
                            type: message.type,
                            sender: message.sender,
                            date: message.sentAt,
                            disclaimer: nil
                        )
                    ],
                    hasPreviousMessages: false
                )
            }
        }
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        await model.messageVm.fetchPreviousMessages(retry: true)

        let successMessages = model.messageVm.messages.filter { $0.status == .sent || $0.status == .received }
        assert(successMessages.count == 1)
        assert(successMessages.first?.type == messageType)
        assert(mockService.events.count == 3)
        assert(mockService.events.first == .getNewMessages)
        assert(mockService.events.last == .getPreviousMessages)
        sut = mockService
    }
}
