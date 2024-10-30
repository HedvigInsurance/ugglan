import PresentableStore
import XCTest
import hCore

@testable import Home

final class HomeTests: XCTestCase {
    weak var sut: MockHomeService?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: HomeClient.self)
        try await Task.sleep(nanoseconds: 100)

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
        self.sut = mockService

        let respondedMessages = try! await mockService.getImportantMessages()
        assert(respondedMessages == importantMessages)
    }

    func testGetMemberStateSuccess() async {
        let memberState: MemberState = .init(
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
        self.sut = mockService

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
        self.sut = mockService

        let respondedQuickActions = try! await mockService.getQuickActions()
        assert(respondedQuickActions == quickActions)
    }

    func testGetLastMessagesDatesSuccess() async {

        let dateOfLastMessage = "2024-07-16".localDateToDate!

        let lastMessagesState = MessageState(
            hasNewMessages: true,
            hasSentOrRecievedAtLeastOneMessage: true,
            lastMessageTimeStamp: nil
        )

        let mockService = MockData.createMockHomeService(
            fetchLatestMessageState: { lastMessagesState }
        )
        self.sut = mockService

        let respondedLastMessages = try! await mockService.getMessagesState()
        assert(respondedLastMessages.hasNewMessages == lastMessagesState.hasNewMessages)
        assert(
            respondedLastMessages.hasSentOrRecievedAtLeastOneMessage
                == lastMessagesState.hasSentOrRecievedAtLeastOneMessage
        )
        assert(respondedLastMessages.lastMessageTimeStamp == lastMessagesState.lastMessageTimeStamp)

    }

    func testHomeStoreWithMultipleActionsAtOnce() async throws {
        for i in 1...10 {
            try await iteratedStoreTest(iteration: i)
        }
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func iteratedStoreTest(iteration: Int) async throws {
        globalPresentableStoreContainer.deletePersistanceContainer()
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
        let memberState = MemberState.init(
            contracts: [],
            contractState: MemberContractState.allCases.randomElement() ?? .active,
            futureState: futureStatus
        )
        MockData.createMockHomeService(
            fetchImportantMessages: {
                try await Task.sleep(nanoseconds: UInt64.random(in: 10_000_000...20_000_000))
                return importantMessages
            },
            fetchMemberState: {
                try await Task.sleep(nanoseconds: UInt64.random(in: 10_000_000...20_000_000))
                return memberState
            },
            fetchQuickActions: {
                try await Task.sleep(nanoseconds: UInt64.random(in: 10_000_000...20_000_000))
                return [
                    .sickAbroad(partners: []),
                    .firstVet(partners: []),
                ]
            },
            fetchLatestMessageState: {
                try await Task.sleep(nanoseconds: UInt64.random(in: 10_000_000...20_000_000))
                return messageState
            }
        )
        print("ITERATION \(iteration)")
        let store = HomeStore()
        let storeInitialLatestConversationTimeStamp = store.state.latestConversationTimeStamp
        store.send(.fetchMemberState)
        store.send(.fetchImportantMessages)
        store.send(.fetchQuickActions)
        store.send(.fetchChatNotifications)
        try await Task.sleep(nanoseconds: 100_000_000)

        assert(store.state.memberContractState == memberState.contractState)
        assert(store.state.futureStatus == memberState.futureState)
        assert(store.state.contracts == memberState.contracts)
        assert(store.state.importantMessages == importantMessages)
        assert(store.state.quickActions.count == 2)
        assert(store.state.toolbarOptionTypes.count == (messageState.hasSentOrRecievedAtLeastOneMessage ? 3 : 2))
        assert(store.state.hidenImportantMessages.count == 0)
        assert(store.state.upcomingRenewalContracts == [])
        assert(store.state.showChatNotification == messageState.hasNewMessages)
        assert(store.state.hasSentOrRecievedAtLeastOneMessage == messageState.hasSentOrRecievedAtLeastOneMessage)
        assert(
            store.state.latestConversationTimeStamp == messageState.lastMessageTimeStamp
                || store.state.latestConversationTimeStamp == storeInitialLatestConversationTimeStamp
        )
    }
}
