@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelIsConversationOpen: XCTestCase {
    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testIsConverationOpenSuccess() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationStatus: .open) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.conversationStatus == .open)
        sut = mockService
    }

    func testIsConverationOpenFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let initialValue = model.messageVm.conversationVm.conversationStatus
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.conversationStatus == initialValue)
        sut = mockService
    }

    func testIsConverationClosedSuccess() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationStatus: .closed) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.conversationStatus == .closed)
        sut = mockService
    }

    func testIsConverationClosedFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let initialValue = model.messageVm.conversationVm.conversationStatus
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.conversationStatus == initialValue)
        sut = mockService
    }
}
