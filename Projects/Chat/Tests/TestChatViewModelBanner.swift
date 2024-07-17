import XCTest

@testable import Chat

final class TestChatViewModelBanner: XCTestCase {

    weak var sut: MockConversationService?
    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        XCTAssertNil(sut)
    }

    func testBannerSuccess() async {
        let banner = "testBanner"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(banner: banner) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.banner == banner)
        self.sut = mockService
    }

    func testBannerFailure() async {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { throw ChatError.fetchMessagesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let chatInitialBanner = model.banner
        await model.startFetchingNewMessages()
        assert(model.banner == chatInitialBanner)
        self.sut = mockService
    }

    func testFetchBannerAfterFetchingPreviousMessagesSuccess() async {
        let banner = "testBanner"
        let updatedBanner = "updatedBanner"
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(hasPreviousMessages: true, banner: banner) },
            fetchPreviousMessages: { .init(banner: updatedBanner) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.startFetchingNewMessages()
        assert(model.banner == banner)
        await model.fetchPreviousMessages(retry: false)
        assert(model.banner == updatedBanner)
        self.sut = mockService
    }

}
