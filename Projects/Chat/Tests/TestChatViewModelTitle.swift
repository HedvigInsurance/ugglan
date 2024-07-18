import XCTest

@testable import Chat

final class TestChatViewModelTitle: XCTestCase {

    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        XCTAssertNil(sut)
    }

    func testFetchTitleSuccess() async {
        let title = "testTitle"
        let subtitle = "testSubTitle"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(title: title, subtitle: subtitle) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.title == title)
        assert(model.subTitle == subtitle)
        self.sut = mockService
    }

    func testFetchTitleFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let chatInitialTitle = model.title
        let chatInitialSubtitle = model.subTitle
        await model.startFetchingNewMessages()
        assert(model.title == chatInitialTitle)
        assert(model.subTitle == chatInitialSubtitle)
        self.sut = mockService
    }

    /// Previous messages shouldn't affect title and subtitle
    func testFetchTitleAfterFetchingPreviousMessagesSuccess() async {
        let title = "testTitle"
        let subtitle = "testSubTitle"
        let updatedTitle = "updatedTitle"
        let updatedSubtitle = "updatedSubTitle"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(hasPreviousMessages: true, title: title, subtitle: subtitle) },
            fetchPreviousMessages: { .init(title: updatedTitle, subtitle: updatedSubtitle) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.title == title)
        assert(model.subTitle == subtitle)
        await model.fetchPreviousMessages(retry: false)
        assert(model.title == title)
        assert(model.subTitle == subtitle)
        self.sut = mockService
    }

}
