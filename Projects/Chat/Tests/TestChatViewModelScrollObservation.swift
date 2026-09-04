import Combine
import XCTest

@testable import Chat

@MainActor
final class TestChatViewModelScrollObservation: XCTestCase {
    weak var sut: MockConversationService?

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(sut)
    }

    func testScrollObservationHidesBottomMenu() {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "", banner: nil) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        let isScrolling = PassthroughSubject<Bool, Never>()
        model.chatInputVm.showBottomMenu = true

        model.observeScrolling(isScrolling)

        // `subscribe(on: RunLoop.main)` defers both the upstream subscribe and the demand it
        // requests to later run-loop turns, and the subject drops anything sent before that.
        for turn in 1...2 {
            let pumped = expectation(description: "run loop turn \(turn)")
            RunLoop.main.perform { pumped.fulfill() }
            wait(for: [pumped], timeout: 1)
        }
        isScrolling.send(true)

        XCTAssertFalse(model.chatInputVm.showBottomMenu)
        sut = mockService
    }

    func testScrollObservationDoesNotRetainViewModel() {
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "", banner: nil) }
        )
        var model: ChatScreenViewModel? = ChatScreenViewModel(chatService: mockService)
        weak var weakModel = model
        let isScrolling = PassthroughSubject<Bool, Never>()

        model?.observeScrolling(isScrolling)
        isScrolling.send(true)
        model = nil

        XCTAssertNil(weakModel, "the sink stored on scrollCancellable must not hold the view model")
        sut = mockService
    }
}
