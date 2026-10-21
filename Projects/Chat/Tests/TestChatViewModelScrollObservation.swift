import Combine
import Foundation
import Testing

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelScrollObservation {
        private weak var sut: MockConversationService?

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() {
            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func scrollObservationHidesBottomMenu() {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "", banner: nil) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                let isScrolling = PassthroughSubject<Bool, Never>()
                model.chatInputVm.showBottomMenu = true

                model.observeScrolling(isScrolling)
                #expect(model.scrollCancellable != nil, "observeScrolling must store the subscription")

                // subscribe(on: RunLoop.main) subscribes on later run-loop turns; anything sent before is dropped.
                for _ in 1...2 {
                    RunLoop.main.run(until: Date().addingTimeInterval(0.01))
                }
                isScrolling.send(true)

                #expect(model.chatInputVm.showBottomMenu == false)
                sut = mockService
            }

            expectServiceReleased()
        }

        @Test
        func scrollObservationDoesNotRetainViewModel() {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "", banner: nil) }
                )
                var model: ChatScreenViewModel? = ChatScreenViewModel(chatService: mockService)
                weak let weakModel = model
                let isScrolling = PassthroughSubject<Bool, Never>()

                model?.observeScrolling(isScrolling)
                #expect(model?.scrollCancellable != nil, "observeScrolling must store the subscription")
                model = nil

                #expect(weakModel == nil, "the sink stored on scrollCancellable must not hold the view model")
                sut = mockService
            }

            expectServiceReleased()
        }
    }
}
