import Foundation
import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelPollingRetain: XCTestCase {
    weak var sut: MockConversationService?

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testStartFetchingNewMessagesDoesNotRetainViewModel() async {
        let mockService = MockData.createMockChatService()
        var model: ChatScreenViewModel? = ChatScreenViewModel(chatService: mockService)
        weak var weakModel = model

        await model?.startFetchingNewMessages()

        // `pollTimerCancellable` is private, so the timer sink cannot be inspected from here. The
        // fetch that runs directly after the sink is stored is the observable proof it was created.
        XCTAssertTrue(
            mockService.events.contains(.getNewMessages),
            "startFetchingNewMessages must reach its fetch, otherwise no timer sink was stored"
        )

        // The awaited fetch returns through Foundation/Combine, which can leave the view model in
        // the enclosing autorelease pool; drain a pool of our own so a non-nil weak read below
        // means a real cycle rather than a pending release.
        autoreleasepool {
            model = nil
        }

        XCTAssertNil(weakModel, "the sink stored on pollTimerCancellable must not hold the view model")
        sut = mockService
    }
}
