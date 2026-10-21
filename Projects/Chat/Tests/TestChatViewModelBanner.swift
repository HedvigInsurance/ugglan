import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelBanner {
        private weak var sut: MockConversationService?
        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func bannerSuccess() async {
            do {
                let banner = "testBanner"
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "", banner: banner) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.banner == banner)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func bannerFailure() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { throw ChatError.fetchMessagesFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                let chatInitialBanner = model.messageVm.conversationVm.banner
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.banner == chatInitialBanner)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func fetchBannerAfterFetchingPreviousMessagesSuccess() async {
            do {
                let banner = "testBanner"
                let updatedBanner = "updatedBanner"
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "", hasPreviousMessages: true, banner: banner) },
                    fetchPreviousMessages: { .init(conversationId: "", banner: updatedBanner) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.banner == banner)
                await model.messageVm.fetchPreviousMessages(retry: false)
                #expect(model.messageVm.conversationVm.banner == updatedBanner)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
