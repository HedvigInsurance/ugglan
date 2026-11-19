import AppStateContainer
import Foundation
import TestDependencies
import Testing
import hCore

@testable import MessagesCore

extension MessagesDependencySuite {
    @MainActor
    final class MessagesStoreTests {
        private weak var store: MessagesStore?
        private weak var sut: MockMessagesClient?

        private let messages: [InboxMessage] = [
            MockData.message(id: "email-1", receivedAt: .init(timeIntervalSince1970: 300)),
            MockData.message(id: "sms-1", channel: .sms, receivedAt: .init(timeIntervalSince1970: 200)),
            MockData.message(id: "kivra-1", channel: .kivra, receivedAt: .init(timeIntervalSince1970: 100)),
        ]

        init() {
            globalAppStateContainer.clearPersistence()
        }

        private func expectStoreReleased() async {
            await waitUntil(description: "MessagesStore deinit") { self.store == nil }
            Dependencies.shared.remove(for: MessagesClient.self)
            await delay(0.00001)
            #expect(sut == nil, "the mock client must not outlive the test that created it")
        }

        @Test
        func fetchMessagesSuccess() async {
            do {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(fetchMessages: { messages })
                sut = client
                let store = MessagesStore()
                self.store = store

                #expect(store.state.isNotLoaded)
                await store.fetchMessages()

                #expect(store.state.value == messages)
                #expect(store.messages == messages)
                #expect(client.events == [.getMessages])
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMessagesFirstLoadFailure() async {
            do {
                let client = MockData.createMockMessagesClient(fetchMessages: { throw MockMessagesError.fetchMessages })
                sut = client
                let store = MessagesStore()
                self.store = store

                await store.fetchMessages()

                #expect(store.state.isFailed)
                #expect(store.messages.isEmpty)
                #expect(client.events == [.getMessages])
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMessagesShowsLoadingOnFirstLoad() async {
            do {
                let messages = self.messages
                var observedState: String?
                weak var weakStore: MessagesStore?
                let client = MockData.createMockMessagesClient(fetchMessages: {
                    observedState = weakStore.map { $0.state.isLoading ? "loading" : "other" }
                    return messages
                })
                sut = client
                let store = MessagesStore()
                weakStore = store
                self.store = store

                await store.fetchMessages()

                #expect(observedState == "loading")
                #expect(store.state.value == messages)
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMessagesRefreshFailureKeepsLoadedList() async {
            do {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(fetchMessages: { messages })
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                var observedStateDuringRefresh: [InboxMessage]?
                weak let weakStore = store
                client.fetchMessages = {
                    observedStateDuringRefresh = weakStore?.state.value
                    throw MockMessagesError.fetchMessages
                }
                await store.fetchMessages()

                #expect(observedStateDuringRefresh == messages, "refresh must not replace the list with a loader")
                #expect(store.state.value == messages)
                #expect(client.events == [.getMessages, .getMessages])
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMessagesRefreshSuccessReplacesList() async {
            do {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(fetchMessages: { messages })
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                let refreshed = [MockData.message(id: "new")]
                client.fetchMessages = { refreshed }
                await store.fetchMessages()

                #expect(store.messages == refreshed)
            }

            await expectStoreReleased()
        }

        @Test
        func messageWithIdSuccess() async {
            do {
                let messages = self.messages
                sut = MockData.createMockMessagesClient(fetchMessages: { messages })
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                #expect(store.message(with: "sms-1")?.channel == .sms)
                #expect(store.message(with: "missing") == nil)
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMessagesRefreshKeepsLoadedBodies() async {
            await recordingErrors {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { id in .init(body: "body \(id)", preview: nil) }
                )
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()
                try await store.loadBody(messageId: "email-1")
                try await store.loadBody(messageId: "sms-1")

                // The refreshed list carries no bodies, drops sms-1 and adds a new message.
                let refreshed = [
                    MockData.message(id: "email-1", receivedAt: .init(timeIntervalSince1970: 300)),
                    MockData.message(id: "new", receivedAt: .init(timeIntervalSince1970: 400)),
                ]
                client.fetchMessages = { refreshed }
                await store.fetchMessages()

                #expect(store.messages.map(\.id) == ["email-1", "new"])
                #expect(store.message(with: "email-1")?.body == "body email-1")
                #expect(store.message(with: "new")?.body == nil)
                #expect(store.message(with: "sms-1") == nil)
                #expect(
                    client.events == [
                        .getMessages,
                        .getMessageContent(messageId: "email-1"),
                        .getMessageContent(messageId: "sms-1"),
                        .getMessages,
                    ]
                )
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMessagesRefreshPrefersFetchedBody() async {
            await recordingErrors {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { _ in .init(body: "loaded body", preview: nil) }
                )
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()
                try await store.loadBody(messageId: "email-1")

                let refreshed = [
                    MockData.message(id: "email-1", receivedAt: .init(timeIntervalSince1970: 300), body: "fetched body")
                ]
                client.fetchMessages = { refreshed }
                await store.fetchMessages()

                #expect(store.message(with: "email-1")?.body == "fetched body")
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodySuccess() async {
            await recordingErrors {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { id in .init(body: "<p>body \(id)</p>", preview: nil) }
                )
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                try await store.loadBody(messageId: "sms-1")

                #expect(store.message(with: "sms-1")?.body == "<p>body sms-1</p>")
                #expect(store.message(with: "email-1")?.body == nil, "only the requested message gets a body")
                #expect(store.messages.map(\.id) == messages.map(\.id), "loading a body must not reorder the list")
                #expect(client.events == [.getMessages, .getMessageContent(messageId: "sms-1")])
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyFillsMissingPreviewSuccess() async {
            await recordingErrors {
                let messages = [MockData.message(id: "email-1", preview: nil)]
                sut = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { _ in .init(body: "body", preview: "preheader") }
                )
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                try await store.loadBody(messageId: "email-1")

                #expect(store.message(with: "email-1")?.preview == "preheader")
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyKeepsExistingPreviewSuccess() async {
            await recordingErrors {
                let messages = [MockData.message(id: "email-1", preview: "from list")]
                sut = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { _ in .init(body: "body", preview: "from content") }
                )
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                try await store.loadBody(messageId: "email-1")

                #expect(store.message(with: "email-1")?.preview == "from list")
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyAlreadyLoadedSkipsClient() async {
            await recordingErrors {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { _ in .init(body: "body", preview: nil) }
                )
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                try await store.loadBody(messageId: "email-1")
                client.getMessageContent = { _ in .init(body: "another body", preview: nil) }
                try await store.loadBody(messageId: "email-1")

                #expect(store.message(with: "email-1")?.body == "body")
                #expect(client.events == [.getMessages, .getMessageContent(messageId: "email-1")])
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyFetchedWithListSkipsClient() async {
            await recordingErrors {
                let messages = [MockData.message(id: "with-body", body: "from list")]
                let client = MockData.createMockMessagesClient(fetchMessages: { messages })
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                try await store.loadBody(messageId: "with-body")

                #expect(store.message(with: "with-body")?.body == "from list")
                #expect(client.events == [.getMessages])
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyUnknownIdSkipsClient() async {
            await recordingErrors {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(fetchMessages: { messages })
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                try await store.loadBody(messageId: "missing")

                #expect(store.messages == messages)
                #expect(client.events == [.getMessages])
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyBeforeFetchSkipsClient() async {
            await recordingErrors {
                let client = MockData.createMockMessagesClient()
                sut = client
                let store = MessagesStore()
                self.store = store

                try await store.loadBody(messageId: "email-1")

                #expect(store.state.isNotLoaded)
                #expect(client.events.isEmpty)
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyFailure() async {
            do {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { _ in throw MockMessagesError.getMessageContent }
                )
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                await #expect(throws: MockMessagesError.self) {
                    try await store.loadBody(messageId: "email-1")
                }

                #expect(store.message(with: "email-1")?.body == nil)
                #expect(store.messages == messages)
                #expect(client.events == [.getMessages, .getMessageContent(messageId: "email-1")])
            }

            await expectStoreReleased()
        }

        @Test
        func loadBodyRetriesAfterFailureSuccess() async {
            await recordingErrors {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    getMessageContent: { _ in throw MockMessagesError.getMessageContent }
                )
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                await #expect(throws: MockMessagesError.self) {
                    try await store.loadBody(messageId: "email-1")
                }
                client.getMessageContent = { _ in .init(body: "body", preview: nil) }
                try await store.loadBody(messageId: "email-1")

                #expect(store.message(with: "email-1")?.body == "body")
                #expect(
                    client.events == [
                        .getMessages,
                        .getMessageContent(messageId: "email-1"),
                        .getMessageContent(messageId: "email-1"),
                    ]
                )
            }

            await expectStoreReleased()
        }

        @Test
        func messagesStoreDeallocatesAfterFetchAndLoadBody() async {
            await recordingErrors {
                let messages = self.messages
                sut = MockData.createMockMessagesClient(fetchMessages: { messages })
                try await assertDeallocates({ MessagesStore() }) { store in
                    await store.fetchMessages()
                    try await store.loadBody(messageId: "email-1")
                }
            }

            await expectStoreReleased()
        }
    }
}

extension LoadState {
    fileprivate var isNotLoaded: Bool {
        if case .notLoaded = self { return true }
        return false
    }

    fileprivate var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    fileprivate var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }
}
