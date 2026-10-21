import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelIsConversationOpen {
        private weak var sut: MockConversationService?
        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func isConverationOpenSuccess() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationStatus: .open) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.conversationStatus == .open)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func isConverationOpenFailure() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { throw ChatError.fetchMessagesFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                let initialValue = model.messageVm.conversationVm.conversationStatus
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.conversationStatus == initialValue)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func isConverationClosedSuccess() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationStatus: .closed) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.conversationStatus == .closed)
                sut = mockService
            }

            await expectServiceReleased()
        }

        @Test
        func isConverationClosedFailure() async {
            do {
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { throw ChatError.fetchMessagesFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                let initialValue = model.messageVm.conversationVm.conversationStatus
                await model.startFetchingNewMessages()
                #expect(model.messageVm.conversationVm.conversationStatus == initialValue)
                sut = mockService
            }

            await expectServiceReleased()
        }
    }
}
