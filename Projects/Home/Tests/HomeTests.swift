import AppStateContainer
import Foundation
import TestDependencies
import Testing
import hCore

@testable import Home

extension HomeDependencySuite {
    @MainActor
    final class HomeTests {
        private weak var sut: MockHomeService?

        init() {
            globalAppStateContainer.clearPersistence()
            UserDefaults.standard.removeObject(forKey: DismissedOngoingQuotesTracker.storageKey)
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        }

        // Test bodies are scoped in a do block or recordingErrors so their locals are released before this check.
        private func expectServiceReleased() async {
            UserDefaults.standard.removeObject(forKey: DismissedOngoingQuotesTracker.storageKey)
            Dependencies.shared.remove(for: HomeClient.self)
            await delay(0.0000001)

            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func getImportantMessagesSuccess() async {
            await recordingErrors {
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

                let respondedMessages = try await mockService.getImportantMessages()
                #expect(respondedMessages == importantMessages)
            }

            await expectServiceReleased()
        }

        @Test
        func getMemberStateSuccess() async {
            await recordingErrors {
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

                let respondedMemberState = try await mockService.getMemberState()
                #expect(respondedMemberState.contractState == memberState.contractState)
                #expect(respondedMemberState.contracts == memberState.contracts)
                #expect(respondedMemberState.futureState == memberState.futureState)
                #expect(respondedMemberState.memberInfo == memberState.memberInfo)
            }

            await expectServiceReleased()
        }

        @Test
        func fetchMemberStateFirstNameSuccess() async {
            do {
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

                #expect(store.memberInfo?.firstName == "Victor")
            }

            await expectServiceReleased()
        }

        @Test
        func fetchOngoingQuotesSuccess() async {
            do {
                let quotes = [Self.makeOngoingQuote(id: "1"), Self.makeOngoingQuote(id: "2")]
                let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
                sut = mockService

                let store = HomeStore()
                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                }

                #expect(store.ongoingQuotes == quotes)
            }

            await expectServiceReleased()
        }

        @Test
        func fetchOngoingQuotesFailureLeavesQuotesEmpty() async {
            do {
                let mockService = MockData.createMockHomeService(
                    fetchOngoingQuotes: { throw NetworkError.badRequest(message: nil) }
                )
                sut = mockService

                let store = HomeStore()
                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                }

                #expect(store.ongoingQuotes.isEmpty)
            }

            await expectServiceReleased()
        }

        @Test
        func fetchOngoingQuotesWithFlagOffSkipsTheService() async {
            do {
                let mockService = MockData.createMockHomeService(
                    fetchOngoingQuotes: { [Self.makeOngoingQuote(id: "1")] }
                )
                sut = mockService

                let store = HomeStore()
                await withOngoingQuotesFlag(enabled: false) {
                    await store.fetchOngoingQuotes()
                }

                #expect(store.ongoingQuotes.isEmpty)
                #expect(mockService.events.contains(.getOngoingQuotes) == false)
            }

            await expectServiceReleased()
        }

        /// On a cold launch the flag is still off at fetch time; the quotes must arrive when it turns on.
        @Test
        func ongoingQuotesLoadWhenTheFlagArrivesAfterTheFirstFetch() async {
            await recordingErrors {
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
                #expect(store.ongoingQuotes.isEmpty)

                mockClient.send(.allOff(isResumingOngoingShopSessionsEnabled: true))
                await waitUntil(description: "Ongoing quotes are set when the flag turns on") {
                    store.ongoingQuotes == quotes
                }

                mockClient.send(.allOff())
                await waitUntil(description: "Ongoing quotes are cleared when the flag turns off") {
                    store.ongoingQuotes.isEmpty
                }
            }

            Dependencies.shared.remove(for: FeatureFlagsClient.self)
            await expectServiceReleased()
        }

        @Test
        func ongoingQuoteSecondaryTextPrefersPriceOverSubtitle() async {
            do {
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

                #expect(withPrice.secondaryText != "Studio apartment, Stockholm")
                #expect(withoutPrice.secondaryText == "Studio apartment, Stockholm")
            }

            await expectServiceReleased()
        }

        @Test
        func fetchOngoingQuotesHidesQuotesTheMemberAlreadyDismissed() async {
            await recordingErrors {
                let quotes = [Self.makeOngoingQuote(id: "1"), Self.makeOngoingQuote(id: "2")]
                let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
                sut = mockService

                let store = HomeStore()
                await store.fetchMemberState()
                let memberId = try #require(store.memberInfo?.id)
                DismissedOngoingQuotesTracker().dismiss(quoteId: "1", forMember: memberId)

                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                }

                #expect(store.ongoingQuotes.map(\.id) == ["2"])
            }

            await expectServiceReleased()
        }

        @Test
        func dismissOngoingQuoteHidesItImmediatelyAndStaysHiddenAfterARefetch() async {
            do {
                let quotes = [Self.makeOngoingQuote(id: "1"), Self.makeOngoingQuote(id: "2")]
                let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
                sut = mockService

                let store = HomeStore()
                await store.fetchMemberState()
                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                    store.dismissOngoingQuote(id: "1")

                    #expect(store.ongoingQuotes.map(\.id) == ["2"])

                    await store.fetchOngoingQuotes()
                }

                #expect(store.ongoingQuotes.map(\.id) == ["2"])
            }

            await expectServiceReleased()
        }

        @Test
        func quotesDismissedByAnotherMemberAreStillShown() async {
            do {
                let quotes = [Self.makeOngoingQuote(id: "1")]
                let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
                sut = mockService

                DismissedOngoingQuotesTracker().dismiss(quoteId: "1", forMember: "some-other-member")

                let store = HomeStore()
                await store.fetchMemberState()
                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                }

                #expect(store.ongoingQuotes.map(\.id) == ["1"])
            }

            await expectServiceReleased()
        }

        @Test
        func dismissOngoingQuoteBeforeTheMemberIdArrivesIsNotRemembered() async {
            do {
                let quotes = [Self.makeOngoingQuote(id: "1"), Self.makeOngoingQuote(id: "2")]
                let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
                sut = mockService

                let store = HomeStore()
                #expect(store.memberInfo == nil)

                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                    store.dismissOngoingQuote(id: "1")

                    #expect(store.ongoingQuotes.map(\.id) == ["2"])

                    await store.fetchMemberState()
                    await store.fetchOngoingQuotes()
                }

                #expect(store.ongoingQuotes.map(\.id) == ["1", "2"])
                #expect(DismissedOngoingQuotesTracker().dismissedIds(forMember: "id").isEmpty)
            }

            await expectServiceReleased()
        }

        @Test
        func quotesDismissedEarlierAreHiddenWhenTheMemberIdArrivesAfterTheFetch() async {
            do {
                let memberState: MemberState = .init(
                    memberInfo: .init(id: "member-1", firstName: "Test", isContactInfoUpdateNeeded: false),
                    contracts: [],
                    contractState: .active,
                    futureState: .none
                )
                let quotes = [Self.makeOngoingQuote(id: "1"), Self.makeOngoingQuote(id: "2")]
                let mockService = MockData.createMockHomeService(
                    fetchMemberState: { memberState },
                    fetchOngoingQuotes: { quotes }
                )
                sut = mockService

                DismissedOngoingQuotesTracker().dismiss(quoteId: "1", forMember: "member-1")

                let store = HomeStore()
                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                    #expect(store.ongoingQuotes.map(\.id) == ["1", "2"])

                    await store.fetchMemberState()
                }

                #expect(store.ongoingQuotes.map(\.id) == ["2"])
            }

            await expectServiceReleased()
        }

        @Test
        func dismissedQuotesStayHiddenForAStoreBuiltFromScratch() async {
            do {
                let quotes = [Self.makeOngoingQuote(id: "1"), Self.makeOngoingQuote(id: "2")]
                let mockService = MockData.createMockHomeService(fetchOngoingQuotes: { quotes })
                sut = mockService

                let store = HomeStore()
                await store.fetchMemberState()
                await withOngoingQuotesFlag(enabled: true) {
                    await store.fetchOngoingQuotes()
                    store.dismissOngoingQuote(id: "1")
                }

                globalAppStateContainer.clearPersistence()

                let storeAfterRelaunch = HomeStore()
                await storeAfterRelaunch.fetchMemberState()
                await withOngoingQuotesFlag(enabled: true) {
                    await storeAfterRelaunch.fetchOngoingQuotes()
                }

                #expect(storeAfterRelaunch.ongoingQuotes.map(\.id) == ["2"])
            }

            await expectServiceReleased()
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

        @Test
        func getQuickActionsSuccess() async {
            await recordingErrors {
                let quickActions: [QuickAction] = [
                    .cancellation, .travelInsurance, .connectPayments, .editCoInsured,
                ]

                let mockService = MockData.createMockHomeService(
                    fetchQuickActions: { quickActions }
                )
                sut = mockService

                let respondedQuickActions = try await mockService.getQuickActions()
                #expect(respondedQuickActions == quickActions)
            }

            await expectServiceReleased()
        }

        @Test
        func getLastMessagesDatesSuccess() async {
            await recordingErrors {
                let lastMessagesState = MessageState(
                    hasNewMessages: true,
                    hasSentOrRecievedAtLeastOneMessage: true,
                    lastMessageTimeStamp: nil
                )

                let mockService = MockData.createMockHomeService(
                    fetchLatestMessageState: { lastMessagesState }
                )
                sut = mockService

                let respondedLastMessages = try await mockService.getMessagesState()
                #expect(respondedLastMessages.hasNewMessages == lastMessagesState.hasNewMessages)
                #expect(
                    respondedLastMessages.hasSentOrRecievedAtLeastOneMessage
                        == lastMessagesState.hasSentOrRecievedAtLeastOneMessage
                )
                #expect(respondedLastMessages.lastMessageTimeStamp == lastMessagesState.lastMessageTimeStamp)
            }

            await expectServiceReleased()
        }

        @Test
        func toolbarShowsChatIconWhenNewConversationFromInboxFlagIsOn() async {
            await recordingErrors {
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
            }

            Dependencies.shared.remove(for: FeatureFlagsClient.self)
            await expectServiceReleased()
        }

        // Each case gets a fresh suite instance, so every iteration starts from a cleared store and is leak-checked.
        @Test(arguments: 1...50)
        func homeStoreWithMultipleActionsAtOnce(_ iteration: Int) async {
            do {
                let messageState = Home.MessageState(
                    hasNewMessages: Bool.random(),
                    hasSentOrRecievedAtLeastOneMessage: Bool.random(),
                    lastMessageTimeStamp: Date()
                )
                let importantMessages: [ImportantMessage] = [
                    ImportantMessage(id: "id", message: "message", linkInfo: nil)
                ]
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
                sut = MockData.createMockHomeService(
                    fetchImportantMessages: {
                        await delay(TimeInterval.random(in: 0.01...0.02))
                        return importantMessages
                    },
                    fetchMemberState: {
                        await delay(TimeInterval.random(in: 0.01...0.02))
                        return memberState
                    },
                    fetchQuickActions: {
                        await delay(TimeInterval.random(in: 0.01...0.02))
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
                        await delay(TimeInterval.random(in: 0.01...0.02))
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
                #expect(store.memberContractState == memberState.contractState)
                #expect(store.futureStatus == memberState.futureState)
                #expect(store.contracts == memberState.contracts)
                #expect(store.importantMessages == importantMessages)
                #expect(store.quickActions.count == 2)
                #expect(store.toolbarOptionTypes.count == (messageState.hasSentOrRecievedAtLeastOneMessage ? 3 : 2))
                #expect(store.hidenImportantMessages.count == 0)
                #expect(store.upcomingRenewalContracts == [])
                #expect(store.showChatNotification == messageState.hasNewMessages)
                #expect(store.hasSentOrRecievedAtLeastOneMessage == messageState.hasSentOrRecievedAtLeastOneMessage)
                #expect(
                    store.latestConversationTimeStamp == messageState.lastMessageTimeStamp
                        || store.latestConversationTimeStamp == storeInitialLatestConversationTimeStamp
                )
            }

            await expectServiceReleased()
        }
    }
}
