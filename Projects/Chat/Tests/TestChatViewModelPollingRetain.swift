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

        @Test
        func openDeepLinkDoesNotRetainViewModel() async {
            do {
                let mockService = MockData.createMockChatService()
                var model: ChatScreenViewModel? = ChatScreenViewModel(chatService: mockService)
                weak let weakModel = model

                // A help-center link is the only case the sink does work for, so a strong capture would show.
                let deepLinkUrl = DeepLink.helpCenter.url
                #expect(
                    DeepLink.getType(from: deepLinkUrl) == .helpCenter,
                    "precondition: the posted URL must parse as the help-center deep link"
                )

                NotificationCenter.default.post(name: .openDeepLink, object: deepLinkUrl)

                // Released without suspending, so anything the sink left queued would still be holding it.
                model = nil

                #expect(weakModel == nil, "the openDeepLink sink must not hold the view model")
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func openDeepLinkToHelpCenterLogsEventBeforeTheModelIsFreed() async {
            let originalLog = log
            do {
                let logger = MockData.createMockLogger()
                let mockService = MockData.createMockChatService()
                var model: ChatScreenViewModel? = ChatScreenViewModel(chatService: mockService)
                weak let weakModel = model

                NotificationCenter.default.post(name: .openDeepLink, object: DeepLink.helpCenter.url)
                // Freed straight after the post, as when the link dismisses the chat.
                model = nil
                #expect(weakModel == nil)

                let events = logger.userActions.filter { $0.name == "Help center opened from the chat" }
                #expect(events.count == 1, "the help-center link must be logged once, even if the chat is freed")
                #expect(events.first?.attributes["haveSentAMessage"] == "false")
                sut = mockService
            }
            log = originalLog

            await expectServiceReleased()
        }
    }
}
