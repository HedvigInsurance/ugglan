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
            fetchNewMessages: { .init(isConversationOpen: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.isConversationOpen)
        self.sut = mockService
    }

    func testIsConverationOpenFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let initialValue = model.isConversationOpen
        await model.startFetchingNewMessages()
        assert(model.isConversationOpen == initialValue)
        self.sut = mockService
    }

    func testIsConverationClosedSuccess() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(isConversationOpen: false) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(!model.isConversationOpen)
        self.sut = mockService
    }

    func testIsConverationClosedFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let initialValue = model.isConversationOpen
        await model.startFetchingNewMessages()
        assert(model.isConversationOpen == initialValue)
        self.sut = mockService
    }

}
