@preconcurrency import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelBanner: XCTestCase {
    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testBannerSuccess() async {
        let banner = "testBanner"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "", banner: banner) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.banner == banner)
        sut = mockService
    }

    func testBannerFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let chatInitialBanner = model.messageVm.conversationVm.banner
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.banner == chatInitialBanner)
        sut = mockService
    }

    func testFetchBannerAfterFetchingPreviousMessagesSuccess() async {
        let banner = "testBanner"
        let updatedBanner = "updatedBanner"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "", hasPreviousMessages: true, banner: banner) },
            fetchPreviousMessages: { .init(conversationId: "", banner: updatedBanner) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.messageVm.conversationVm.banner == banner)
        await model.messageVm.fetchPreviousMessages(retry: false)
        assert(model.messageVm.conversationVm.banner == updatedBanner)
        sut = mockService
    }
}
