@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelTitle: XCTestCase {
    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testFetchTitleSuccess() async {
        let title = "testTitle"
        let subtitle = "testSubTitle"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "", title: title, subtitle: subtitle) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.title == title)
        assert(model.messageVm.conversationVm.subTitle == subtitle)
        sut = mockService
    }

    func testFetchTitleFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let chatInitialTitle = model.messageVm.conversationVm.title
        let chatInitialSubtitle = model.messageVm.conversationVm.subTitle
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.title == chatInitialTitle)
        assert(model.messageVm.conversationVm.subTitle == chatInitialSubtitle)
        sut = mockService
    }

    /// Previous messages shouldn't affect title and subtitle
    func testFetchTitleAfterFetchingPreviousMessagesSuccess() async {
        let title = "testTitle"
        let subtitle = "testSubTitle"
        let updatedTitle = "updatedTitle"
        let updatedSubtitle = "updatedSubTitle"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: {
                .init(conversationId: "", hasPreviousMessages: true, title: title, subtitle: subtitle)
            },
            fetchPreviousMessages: { .init(conversationId: "", title: updatedTitle, subtitle: updatedSubtitle) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.title == title)
        assert(model.messageVm.conversationVm.subTitle == subtitle)
        await model.messageVm.fetchPreviousMessages(retry: false)
        assert(model.messageVm.conversationVm.title == title)
        assert(model.messageVm.conversationVm.subTitle == subtitle)
        sut = mockService
    }
}
