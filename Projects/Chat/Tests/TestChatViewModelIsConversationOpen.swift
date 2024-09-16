import XCTest

@testable import Chat

final class TestChatViewModelIsConversationOpen: XCTestCase {

    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        XCTAssertNil(sut)
    }

    func testIsConverationOpenSuccess() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationStatus: .open) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.conversationStatus == .open)
        self.sut = mockService
    }

    func testIsConverationOpenFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let initialValue = model.conversationStatus
        await model.startFetchingNewMessages()
        assert(model.conversationStatus == initialValue)
        self.sut = mockService
    }

    func testIsConverationClosedSuccess() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationStatus: .closed) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.conversationStatus == .closed)
        self.sut = mockService
    }

    func testIsConverationClosedFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let initialValue = model.conversationStatus
        await model.startFetchingNewMessages()
        assert(model.conversationStatus == initialValue)
        self.sut = mockService
    }

}
