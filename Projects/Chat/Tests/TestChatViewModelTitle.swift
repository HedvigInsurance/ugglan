import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelTitle {
        private weak var sut: MockConversationService?
        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func fetchTitleSuccess() async {
            do {
                let title = "testTitle"
                let subtitle = "testSubTitle"
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "", title: title, subtitle: subtitle) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.title == title)
                #expect(model.messageVm.conversationVm.subTitle == subtitle)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func fetchTitleFailure() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { throw ChatError.fetchMessagesFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                let chatInitialTitle = model.messageVm.conversationVm.title
                let chatInitialSubtitle = model.messageVm.conversationVm.subTitle
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.title == chatInitialTitle)
                #expect(model.messageVm.conversationVm.subTitle == chatInitialSubtitle)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func fetchTitleAfterFetchingPreviousMessagesSuccess() async {
            do {
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
                #expect(model.messageVm.conversationVm.title == title)
                #expect(model.messageVm.conversationVm.subTitle == subtitle)
                await model.messageVm.fetchPreviousMessages(retry: false)
                #expect(model.messageVm.conversationVm.title == title)
                #expect(model.messageVm.conversationVm.subTitle == subtitle)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
