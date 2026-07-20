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
            memberInfo: .init(id: "id", isContactInfoUpdateNeeded: false),
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

        XCTAssertTrue(store.toolbarOptionTypes.contains(.chat(hasUnread: false)))

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
            memberInfo: .init(id: "id", isContactInfoUpdateNeeded: false),
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
