import AppStateContainer
import XCTest
import hCore

@testable import Home

@MainActor
final class HomeTests: XCTestCase {
    weak var sut: MockHomeService?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: HomeClient.self)
        try await Task.sleep(seconds: 0.0000001)

        XCTAssertNil(sut)
    }

    func testGetImportantMessagesSuccess() async {
        let linkUrl = URL(string: "https://hedvig.com")!
        let importantMessages: [Home.ImportantMessage] = [
            .init(
                id: "id1",
                message: "This is an important message",
                linkInfo: nil
            ),
            .init(
                id: "id2",
                message: "This is another important message with link",
                linkInfo: .init(link: linkUrl, text: "link")
            ),
        ]

        let mockService = MockData.createMockHomeService(
            fetchImportantMessages: { importantMessages }
        )
        sut = mockService

        let respondedMessages = try! await mockService.getImportantMessages()
        assert(respondedMessages == importantMessages)
    }

    func testGetMemberStateSuccess() async {
        let memberState: MemberState = .init(
            memberInfo: .init(id: "id", firstName: "Test", isContactInfoUpdateNeeded: false),
            contracts: [
                .init(
                    upcomingRenewal: nil,
                    displayName: "contract display name"
                )
            ],
            contractState: .active,
            futureState: .none
        )

        let mockService = MockData.createMockHomeService(
            fetchMemberState: { memberState }
        )
        sut = mockService

        let respondedMemberState = try! await mockService.getMemberState()
        assert(respondedMemberState.contractState == memberState.contractState)
        assert(respondedMemberState.contracts == memberState.contracts)
        assert(respondedMemberState.futureState == memberState.futureState)
        assert(respondedMemberState.memberInfo == memberState.memberInfo)
    }

    func testFetchMemberStateFirstNameSuccess() async {
        let memberState: MemberState = .init(
            memberInfo: .init(id: "id", firstName: "Victor", isContactInfoUpdateNeeded: false),
            contracts: [],
            contractState: .active,
            futureState: .none
        )
        let mockService = MockData.createMockHomeService(
            fetchMemberState: { memberState }
        )
        sut = mockService

        let store = HomeStore()
        await store.fetchMemberState()

        XCTAssertEqual(store.memberInfo?.firstName, "Victor")
    }

    func testFetchOngoingQuotesSuccess() async {
        let quotes = [Self.makeOngoingQuote(id: "1"), Self.makeOngoingQuote(id: "2")]
        let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
        sut = mockService

        let store = HomeStore()
        await withOngoingQuotesFlag(enabled: true) {
            await store.fetchOngoingQuotes()
        }

        XCTAssertEqual(store.ongoingQuotes, quotes)
    }

    func testFetchOngoingQuotesFailureLeavesQuotesEmpty() async {
        let mockService = MockData.createMockHomeService(
            fetchOngoingQuotes: { throw NetworkError.badRequest(message: nil) }
        )
        sut = mockService

        let store = HomeStore()
        await withOngoingQuotesFlag(enabled: true) {
            await store.fetchOngoingQuotes()
        }

        XCTAssertTrue(store.ongoingQuotes.isEmpty)
    }

    func testFetchOngoingQuotesWithFlagOffSkipsTheService() async {
        let mockService = MockData.createMockHomeService(
            fetchOngoingQuotes: { [Self.makeOngoingQuote(id: "1")] }
        )
        sut = mockService

        let store = HomeStore()
        await withOngoingQuotesFlag(enabled: false) {
            await store.fetchOngoingQuotes()
        }

        XCTAssertTrue(store.ongoingQuotes.isEmpty)
        XCTAssertFalse(mockService.events.contains(.getOngoingQuotes))
    }

    /// On a cold launch Home fetches before Unleash has answered, so the flag is still off.
    /// The quotes must arrive when the flag does, without the screen being revisited.
    func testOngoingQuotesLoadWhenTheFlagArrivesAfterTheFirstFetch() async throws {
        let mockClient = MockFeatureFlagsClient()
        Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in mockClient })

        try await FeatureFlags.shared.setup(with: [:])
        mockClient.send(.allOff(isResumingOngoingShopSessionsEnabled: false))
        await waitUntil(description: "Flag arrives switched off") {
            FeatureFlags.shared.isResumingOngoingShopSessionsEnabled == false
        }

        let quotes = [Self.makeOngoingQuote(id: "1")]
        let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
        sut = mockService

        let store = HomeStore()
        await store.fetchOngoingQuotes()
        XCTAssertTrue(store.ongoingQuotes.isEmpty)

        mockClient.send(.allOff(isResumingOngoingShopSessionsEnabled: true))
        await waitUntil(description: "Ongoing quotes are set when the flag turns on") {
            store.ongoingQuotes == quotes
        }

        mockClient.send(.allOff())
        await waitUntil(description: "Ongoing quotes are cleared when the flag turns off") {
            store.ongoingQuotes.isEmpty
        }
        Dependencies.shared.remove(for: FeatureFlagsClient.self)
    }

    func testOngoingQuoteSecondaryTextPrefersPriceOverSubtitle() {
        let withPrice = Self.makeOngoingQuote(
            id: "1",
            subtitle: "Studio apartment, Stockholm",
            monthlyNet: .init(amount: "199", currency: "SEK")
        )
        let withoutPrice = Self.makeOngoingQuote(
            id: "2",
            subtitle: "Studio apartment, Stockholm",
            monthlyNet: nil
        )

        XCTAssertNotEqual(withPrice.secondaryText, "Studio apartment, Stockholm")
        XCTAssertEqual(withoutPrice.secondaryText, "Studio apartment, Stockholm")
    }

    private func withOngoingQuotesFlag(enabled: Bool, _ body: () async -> Void) async {
        let previous = FeatureFlags.shared.data
        FeatureFlags.shared.data = .allOff(isResumingOngoingShopSessionsEnabled: enabled)
        await body()
        FeatureFlags.shared.data = previous
    }

    private static func makeOngoingQuote(
        id: String,
        subtitle: String? = "Studio apartment, Stockholm",
        monthlyNet: MonetaryAmount? = .init(amount: "199", currency: "SEK")
    ) -> OngoingQuote {
        .init(
            id: id,
            title: "Home Insurance",
            subtitle: subtitle,
            monthlyNet: monthlyNet,
            resumeUrl: URL(string: "https://hedvig.com/resume/\(id)")!,
            pillowImageUrl: nil
        )
    }

    func testGetQuickActionsSuccess() async {
        let quickActions: [QuickAction] = [
            .cancellation, .travelInsurance, .connectPayments, .editCoInsured,
        ]

        let mockService = MockData.createMockHomeService(
            fetchQuickActions: { quickActions }
        )
        sut = mockService

        let respondedQuickActions = try! await mockService.getQuickActions()
        assert(respondedQuickActions == quickActions)
    }

    func testGetLastMessagesDatesSuccess() async {
        let lastMessagesState = MessageState(
            hasNewMessages: true,
            hasSentOrRecievedAtLeastOneMessage: true,
            lastMessageTimeStamp: nil
        )

        let mockService = MockData.createMockHomeService(
            fetchLatestMessageState: { lastMessagesState }
        )
        sut = mockService

        let respondedLastMessages = try! await mockService.getMessagesState()
        assert(respondedLastMessages.hasNewMessages == lastMessagesState.hasNewMessages)
        assert(
            respondedLastMessages.hasSentOrRecievedAtLeastOneMessage
                == lastMessagesState.hasSentOrRecievedAtLeastOneMessage
        )
        assert(respondedLastMessages.lastMessageTimeStamp == lastMessagesState.lastMessageTimeStamp)
    }

    func testToolbarShowsChatIconWhenNewConversationFromInboxFlagIsOn() async throws {
        let mockClient = MockFeatureFlagsClient()
        Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in mockClient })

        try await FeatureFlags.shared.setup(with: [:])
        mockClient.send(.allOff(isNewConversationFromInboxEnabled: true))

        await waitUntil(description: "Flag propagates to FeatureFlags singleton") {
            FeatureFlags.shared.isNewConversationFromInboxEnabled == true
        }

        let mockService = MockData.createMockHomeService(
            fetchLatestMessageState: {
                MessageState(
                    hasNewMessages: false,
                    hasSentOrRecievedAtLeastOneMessage: false,
                    lastMessageTimeStamp: nil
                )
            }
        )
        sut = mockService

        let store = HomeStore()
        await store.fetchChatNotifications()

        await waitUntil(description: "Toolbar contains chat icon under flag-ON") {
            store.toolbarOptionTypes.contains(.chat(hasUnread: false))
        }

        mockClient.send(.allOff(isNewConversationFromInboxEnabled: false))
        await waitUntil(description: "Flag resets") {
            FeatureFlags.shared.isNewConversationFromInboxEnabled == false
        }
        Dependencies.shared.remove(for: FeatureFlagsClient.self)
    }

    func testHomeStoreWithMultipleActionsAtOnce() async throws {
        for i in 1...50 {
            try await iteratedStoreTest(iteration: i)
            globalAppStateContainer.clearPersistence()
        }
    }

    func iteratedStoreTest(iteration: Int) async throws {
        let messageState = Home.MessageState(
            hasNewMessages: Bool.random(),
            hasSentOrRecievedAtLeastOneMessage: Bool.random(),
            lastMessageTimeStamp: Date()
        )
        let importantMessages: [ImportantMessage] = [ImportantMessage(id: "id", message: "message", linkInfo: nil)]
        let futureStatuses: [FutureStatus] = [
            .none, .pendingNonswitchable, .pendingSwitchable, .activeInFuture(inceptionDate: ""),
        ]
        let randomIndex = Int(arc4random()) % futureStatuses.count
        let futureStatus = futureStatuses[randomIndex]
        let memberState = MemberState(
            memberInfo: .init(id: "id", firstName: "Test", isContactInfoUpdateNeeded: false),
            contracts: [],
            contractState: MemberContractState.allCases.randomElement() ?? .active,
            futureState: futureStatus
        )
        MockData.createMockHomeService(
            fetchImportantMessages: {
                try await Task.sleep(seconds: Float.random(in: 0.01...0.02))
                return importantMessages
            },
            fetchMemberState: {
                try await Task.sleep(seconds: Float.random(in: 0.01...0.02))
                return memberState
            },
            fetchQuickActions: {
                try await Task.sleep(seconds: Float.random(in: 0.01...0.02))
                return [
                    .sickAbroad(
                        deflection: .init(
                            title: nil,
                            content: .init(title: "", description: ""),
                            partners: [],
                            infoText: nil,
                            warningText: nil,
                            questions: [],
                            linkOnlyPartners: [],
                            buttonTitle: ""
                        )
                    ),
                    .firstVet(partners: []),
                ]
            },
            fetchLatestMessageState: {
                try await Task.sleep(seconds: Float.random(in: 0.01...0.02))
                return messageState
            }
        )
        let store = HomeStore()
        let storeInitialLatestConversationTimeStamp = store.latestConversationTimeStamp
        async let m: () = store.fetchMemberState()
        async let i: () = store.fetchImportantMessages()
        async let q: () = store.fetchQuickActions()
        async let c: () = store.fetchChatNotifications()
        _ = await (m, i, q, c)

        await waitUntil(description: "Check home state") {
            store.memberContractState == memberState.contractState
                && store.futureStatus == memberState.futureState && store.contracts == memberState.contracts
                && store.importantMessages == importantMessages && store.quickActions.count == 2
                && store.toolbarOptionTypes.count == (messageState.hasSentOrRecievedAtLeastOneMessage ? 3 : 2)
                && store.hidenImportantMessages.count == 0 && store.upcomingRenewalContracts == []
                && store.showChatNotification == messageState.hasNewMessages
                && store.hasSentOrRecievedAtLeastOneMessage == messageState.hasSentOrRecievedAtLeastOneMessage
                && (store.latestConversationTimeStamp == messageState.lastMessageTimeStamp
                    || store.latestConversationTimeStamp == storeInitialLatestConversationTimeStamp)
        }
        assert(store.memberContractState == memberState.contractState)
        assert(store.futureStatus == memberState.futureState)
        assert(store.contracts == memberState.contracts)
        assert(store.importantMessages == importantMessages)
        assert(store.quickActions.count == 2)
        assert(store.toolbarOptionTypes.count == (messageState.hasSentOrRecievedAtLeastOneMessage ? 3 : 2))
        assert(store.hidenImportantMessages.count == 0)
        assert(store.upcomingRenewalContracts == [])
        assert(store.showChatNotification == messageState.hasNewMessages)
        assert(store.hasSentOrRecievedAtLeastOneMessage == messageState.hasSentOrRecievedAtLeastOneMessage)
        assert(
            store.latestConversationTimeStamp == messageState.lastMessageTimeStamp
                || store.latestConversationTimeStamp == storeInitialLatestConversationTimeStamp
        )
    }
}

@MainActor
extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(seconds: 0.01)
            Task {
                await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
