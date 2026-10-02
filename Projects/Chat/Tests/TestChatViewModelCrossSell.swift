import CrossSell
@preconcurrency import XCTest
import hCore

@testable import Chat

@MainActor
final class TestChatViewModelCrossSell: XCTestCase {
    weak var sut: MockConversationService?
    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: CrossSellClient.self)
        Dependencies.shared.remove(for: URLOpener.self)
        Dependencies.shared.remove(for: ConversationClient.self)
        XCTAssertNil(sut)
    }

    func testServiceCarriesCrossSellGateFromClient() async throws {
        MockData.createMockConversationClient(showCrossSales: true)
        let data = try await ConversationService(conversationId: "conv-1").getNewMessages()
        XCTAssertTrue(data.showCrossSales)
    }

    func testServiceReportsCrossSellGateAsFalseWhenClientDoes() async throws {
        MockData.createMockConversationClient(showCrossSales: false)
        let data = try await ConversationService(conversationId: "conv-1").getNewMessages()
        XCTAssertFalse(data.showCrossSales)
    }

    func testHideCrossSalesForwardsTheConversationId() async throws {
        let client = MockData.createMockConversationClient()
        try await ConversationService(conversationId: "conv-1").hideCrossSales()
        XCTAssertEqual(client.hiddenCrossSalesIds, ["conv-1"])
    }

    func testHideCrossSalesIsANoOpBeforeTheFirstMessage() async throws {
        let client = MockData.createMockConversationClient()
        // Nothing exists server-side until the member sends their first message, so this
        // must not reach the client rather than hiding some other conversation's prompt.
        try await NewConversationService().hideCrossSales()
        XCTAssertTrue(client.hiddenCrossSalesIds.isEmpty)
    }

    func testGateFalseNeverFetchesCrossSell() async {
        let crossSellMock = MockData.createMockCrossSellClient()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: false) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        XCTAssertTrue(crossSellMock.events.isEmpty)
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        sut = mockService
    }

    func testEmptyConversationIdNeverFetchesCrossSell() async {
        let crossSellMock = MockData.createMockCrossSellClient()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        XCTAssertTrue(crossSellMock.events.isEmpty)
        sut = mockService
    }

    func testFetchesOnlyOnceAcrossPolls() async {
        let crossSellMock = MockData.createMockCrossSellClient()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        await model.messageVm.fetchMessages()
        await model.messageVm.fetchMessages()
        XCTAssertEqual(crossSellMock.events.filter { $0 == .getCrossSell }.count, 1)
        sut = mockService
    }

    func testRecommendationRendersItsOwnCopy() async {
        MockData.createMockCrossSellClient()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        let crossSellVm = model.messageVm.crossSellVm
        XCTAssertNotNil(crossSellVm.recommended)
        XCTAssertEqual(crossSellVm.title, "Car insurance")
        XCTAssertEqual(crossSellVm.subtitle, "Insure your car with Hedvig.")
        XCTAssertEqual(crossSellVm.openTitle, "See your price")
        sut = mockService
    }

    func testEmptyRecommendationShowsNoBanner() async {
        MockData.createMockCrossSellClient(
            fetchCrossSell: { _ in .init(recommended: nil, others: []) }
        )
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        XCTAssertEqual(model.messageVm.crossSellVm.title, L10n.crossSellBannerText)
        XCTAssertNil(model.messageVm.crossSellVm.subtitle)
        XCTAssertEqual(model.messageVm.crossSellVm.openTitle, L10n.crossSellButton)
        sut = mockService
    }

    func testFailedFetchShowsNoBanner() async {
        MockData.createMockCrossSellClient(
            fetchCrossSell: { _ in throw ChatError.fetchMessagesFailed }
        )
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        sut = mockService
    }

    func testDismissHidesAndCallsMutation() async {
        MockData.createMockCrossSellClient()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        XCTAssertNotNil(model.messageVm.crossSellVm.recommended)
        await model.messageVm.crossSellVm.dismiss()
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        XCTAssertTrue(mockService.events.contains(.hideCrossSales))
        sut = mockService
    }

    func testDismissStaysHiddenWhenMutationFails() async {
        MockData.createMockCrossSellClient()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) },
            hideCrossSales: { throw ChatError.hideCrossSalesFailed }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        await model.messageVm.crossSellVm.dismiss()
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        // The poll keeps reporting the gate as true; the prompt must not come back.
        await model.messageVm.fetchMessages()
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        sut = mockService
    }

    func testDoubleDismissFiresOneMutation() async {
        MockData.createMockCrossSellClient()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        await model.messageVm.crossSellVm.dismiss()
        await model.messageVm.crossSellVm.dismiss()
        XCTAssertEqual(mockService.events.filter { $0 == .hideCrossSales }.count, 1)
        sut = mockService
    }

    func testOpenOpensStoreUrlHidesAndCallsMutation() async {
        MockData.createMockCrossSellClient()
        let opener = MockData.createMockURLOpener()
        let mockService = MockData.createMockChatService(
            fetchNewMessages: { .init(conversationId: "conv-1", showCrossSales: true) }
        )
        let model = ChatScreenViewModel(chatService: mockService)
        await model.messageVm.fetchMessages()
        await model.messageVm.crossSellVm.open()
        XCTAssertEqual(opener.openedURLs.map(\.absoluteString), ["https://www.hedvig.com/se/car"])
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        XCTAssertTrue(mockService.events.contains(.hideCrossSales))
        sut = mockService
    }

    func testAddonRecommendationOpensDeepLinkNotStoreUrl() async {
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
        XCTAssertTrue(opener.openedURLs.isEmpty)
        XCTAssertNil(model.messageVm.crossSellVm.recommended)
        sut = mockService
    }
}
