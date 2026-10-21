import CrossSell
import Logger
import TestDependencies
import Testing
import hCore

@testable import Chat

extension ChatDependencySuite {
    @MainActor
    final class TestChatViewModelCrossSell {
        private weak var sut: MockConversationService?
        private var logger: MockLogger!
        private var originalLog: (any Logging)!

        init() {
            originalLog = log
            logger = MockData.createMockLogger()
        }

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectLogAndServiceReleased() async {
            log = originalLog
            logger = nil
            Dependencies.shared.remove(for: CrossSellClient.self)
            Dependencies.shared.remove(for: URLOpener.self)
            Dependencies.shared.remove(for: ConversationClient.self)
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func serviceCarriesCrossSellGateFromClient() async {
            await recordingErrors {
                MockData.createMockConversationClient(showCrossSales: true)
                let data = try await ConversationService(conversationId: "conv-1").getNewMessages()
                #expect(data.showCrossSales)
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func serviceReportsCrossSellGateAsFalseWhenClientDoes() async {
            await recordingErrors {
                MockData.createMockConversationClient(showCrossSales: false)
                let data = try await ConversationService(conversationId: "conv-1").getNewMessages()
                #expect(data.showCrossSales == false)
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func hideCrossSalesForwardsTheConversationId() async {
            await recordingErrors {
                let client = MockData.createMockConversationClient()
                try await ConversationService(conversationId: "conv-1").hideCrossSales()
                #expect(client.hiddenCrossSalesIds == ["conv-1"])
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func hideCrossSalesIsANoOpBeforeTheFirstMessage() async {
            await recordingErrors {
                let client = MockData.createMockConversationClient()
                // Nothing exists server-side until the member's first message, so this must not reach the client.
                try await NewConversationService().hideCrossSales()
                #expect(client.hiddenCrossSalesIds.isEmpty)
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func gateFalseNeverFetchesCrossSell() async {
            do {
                let crossSellMock = MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: false) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                #expect(crossSellMock.events.isEmpty)
                #expect(model.messageVm.crossSellVm.recommended == nil)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func emptyConversationIdNeverFetchesCrossSell() async {
            do {
                let crossSellMock = MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                #expect(crossSellMock.events.isEmpty)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func fetchesOnlyOnceAcrossPolls() async {
            do {
                let crossSellMock = MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                await model.messageVm.fetchMessages()
                await model.messageVm.fetchMessages()
                #expect(crossSellMock.events.filter { $0 == .getCrossSell }.count == 1)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func recommendationRendersItsOwnCopy() async {
            do {
                MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                let crossSellVm = model.messageVm.crossSellVm
                #expect(crossSellVm.recommended != nil)
                #expect(crossSellVm.title == "Car insurance")
                #expect(crossSellVm.subtitle == "Insure your car with Hedvig.")
                #expect(crossSellVm.openTitle == "See your price")
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func emptyRecommendationShowsNoBanner() async {
            do {
                MockData.createMockCrossSellClient(
                    fetchCrossSell: { _ in .init(recommended: nil, others: []) }
                )
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                #expect(model.messageVm.crossSellVm.recommended == nil)
                #expect(model.messageVm.crossSellVm.title == L10n.crossSellBannerText)
                #expect(model.messageVm.crossSellVm.subtitle == nil)
                #expect(model.messageVm.crossSellVm.openTitle == L10n.crossSellButton)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func failedFetchShowsNoBanner() async {
            do {
                MockData.createMockCrossSellClient(
                    fetchCrossSell: { _ in throw ChatError.fetchMessagesFailed }
                )
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                #expect(model.messageVm.crossSellVm.recommended == nil)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func dismissHidesAndCallsMutation() async {
            do {
                MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                #expect(model.messageVm.crossSellVm.recommended != nil)
                await model.messageVm.crossSellVm.dismiss()
                #expect(model.messageVm.crossSellVm.recommended == nil)
                #expect(mockService.events.contains(.hideCrossSales))
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func dismissStaysHiddenWhenMutationFails() async {
            do {
                MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) },
                    hideCrossSales: { throw ChatError.hideCrossSalesFailed }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                await model.messageVm.crossSellVm.dismiss()
                #expect(model.messageVm.crossSellVm.recommended == nil)
                // The poll keeps reporting the gate as true; the prompt must not come back.
                await model.messageVm.fetchMessages()
                #expect(model.messageVm.crossSellVm.recommended == nil)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func doubleDismissFiresOneMutation() async {
            do {
                MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                await model.messageVm.crossSellVm.dismiss()
                await model.messageVm.crossSellVm.dismiss()
                #expect(mockService.events.filter { $0 == .hideCrossSales }.count == 1)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func openOpensStoreUrlHidesAndCallsMutation() async {
            do {
                MockData.createMockCrossSellClient()
                let opener = MockData.createMockURLOpener()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                await model.messageVm.crossSellVm.open()
                #expect(opener.openedURLs.map(\.absoluteString) == ["https://www.hedvig.com/se/car"])
                #expect(model.messageVm.crossSellVm.recommended == nil)
                #expect(mockService.events.contains(.hideCrossSales))
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func promptedAndDismissedShareOneFunnelEvent() async {
            do {
                MockData.createMockCrossSellClient()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                // The screen logs "Chat open" from its initialiser; only the prompt's funnel is under test.
                logger.userActions.removeAll()
                await model.messageVm.fetchMessages()
                await model.messageVm.crossSellVm.dismiss()
                // Android reads this funnel by one action name with the variant in "event"; don't rename or split it.
                #expect(logger.userActions.map(\.name) == ["inChatCrossSell", "inChatCrossSell"])
                #expect(logger.userActions.first?.attributes == ["event": "prompted"])
                #expect(logger.userActions.last?.attributes == ["event": "dismissed"])
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func clickedIsRecordedBeforeTheMemberLeaves() async {
            do {
                MockData.createMockCrossSellClient()
                MockData.createMockURLOpener()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                // The screen logs "Chat open" from its initialiser; only the prompt's funnel is under test.
                logger.userActions.removeAll()
                await model.messageVm.fetchMessages()
                await model.messageVm.crossSellVm.open()
                #expect(logger.userActions.map { $0.attributes["event"] } == ["prompted", "clicked"])
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }

        @Test
        func addonRecommendationOpensDeepLinkNotStoreUrl() async {
            do {
                MockData.createMockCrossSellClient(
                    fetchCrossSell: { _ in
                        .init(
                            recommended: .addon(
                                .init(
                                    id: "addon-1",
                                    title: "Travel Plus",
                                    description: "Extended travel cover.",
                                    buttonText: "See your price",
                                    deepLink: "hedvig://addon/travel",
                                    bannerText: "Get a 15% bundle discount",
                                    imageUrl: nil
                                )
                            ),
                            others: []
                        )
                    }
                )
                let opener = MockData.createMockURLOpener()
                let mockService = MockData.createMockChatService(
                    fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
                )
                let model = ChatScreenViewModel(chatService: mockService)
                await model.messageVm.fetchMessages()
                await model.messageVm.crossSellVm.open()
                // Addons route through the deep-link notification, never the web store.
                #expect(opener.openedURLs.isEmpty)
                #expect(model.messageVm.crossSellVm.recommended == nil)
                sut = mockService
            }

            await expectLogAndServiceReleased()
        }
    }
}
