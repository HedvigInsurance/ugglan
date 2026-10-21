import Foundation
import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelPollingRetain {
        private weak var sut: MockConversationService?

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func startFetchingNewMessagesDoesNotRetainViewModel() async {
            do {
                let mockService = MockData.createMockChatService()
                var model: ChatScreenViewModel? = ChatScreenViewModel(chatService: mockService)
                weak let weakModel = model

                await model?.startFetchingNewMessages()

                // pollTimerCancellable is private; the fetch right after the sink is stored proves it was created.
                #expect(
                    mockService.events.contains(.getNewMessages),
                    "startFetchingNewMessages must reach its fetch, otherwise no timer sink was stored"
                )

                // Drain our own autorelease pool so a non-nil weak read means a real cycle, not a pending release.
                autoreleasepool {
                    model = nil
                }

                #expect(weakModel == nil, "the sink stored on pollTimerCancellable must not hold the view model")
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
