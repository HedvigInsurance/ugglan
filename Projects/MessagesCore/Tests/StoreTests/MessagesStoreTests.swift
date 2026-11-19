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
            MockData.message(id: "unread-1", receivedAt: .init(timeIntervalSince1970: 300)),
            MockData.message(id: "unread-2", channel: .sms, receivedAt: .init(timeIntervalSince1970: 200)),
            MockData.message(
                id: "read-1",
                channel: .kivra,
                receivedAt: .init(timeIntervalSince1970: 100),
                isRead: true
            ),
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
                #expect(store.unreadCount == 0)
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
                #expect(store.unreadCount == 2)
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
                #expect(store.unreadCount == 1)
            }

            await expectStoreReleased()
        }

        @Test
        func unreadCountCountsUnreadMessages() async {
            do {
                let messages = self.messages
                sut = MockData.createMockMessagesClient(fetchMessages: { messages })
                let store = MessagesStore()
                self.store = store

                #expect(store.unreadCount == 0)
                await store.fetchMessages()
                #expect(store.unreadCount == 2)
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

                #expect(store.message(with: "unread-2")?.channel == .sms)
                #expect(store.message(with: "missing") == nil)
            }

            await expectStoreReleased()
        }

        @Test
        func markAsReadOptimisticUpdateSuccess() async {
            do {
                let messages = self.messages
                var readStateDuringRequest: Bool?
                weak var weakStore: MessagesStore?
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    markAsRead: { id in readStateDuringRequest = weakStore?.message(with: id)?.isRead }
                )
                sut = client
                let store = MessagesStore()
                weakStore = store
                self.store = store
                await store.fetchMessages()

                await store.markAsRead(messageId: "unread-1")

                #expect(readStateDuringRequest == true, "the message must read as opened before the request finishes")
                #expect(store.message(with: "unread-1")?.isRead == true)
                #expect(store.unreadCount == 1)
                #expect(client.events == [.getMessages, .markAsRead(messageId: "unread-1")])
            }

            await expectStoreReleased()
        }

        @Test
        func markAsReadRevertsOnFailure() async {
            do {
                let messages = self.messages
                var readStateDuringRequest: Bool?
                weak var weakStore: MessagesStore?
                let client = MockData.createMockMessagesClient(
                    fetchMessages: { messages },
                    markAsRead: { id in
                        readStateDuringRequest = weakStore?.message(with: id)?.isRead
                        throw MockMessagesError.markAsRead
                    }
                )
                sut = client
                let store = MessagesStore()
                weakStore = store
                self.store = store
                await store.fetchMessages()

                await store.markAsRead(messageId: "unread-1")

                #expect(readStateDuringRequest == true)
                #expect(store.message(with: "unread-1")?.isRead == false)
                #expect(store.unreadCount == 2)
                #expect(store.messages == messages)
                #expect(client.events == [.getMessages, .markAsRead(messageId: "unread-1")])
            }

            await expectStoreReleased()
        }

        @Test
        func markAsReadAlreadyReadSkipsClient() async {
            do {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(fetchMessages: { messages })
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                await store.markAsRead(messageId: "read-1")

                #expect(store.message(with: "read-1")?.isRead == true)
                #expect(store.unreadCount == 2)
                #expect(client.events == [.getMessages])
            }

            await expectStoreReleased()
        }

        @Test
        func markAsReadUnknownIdSkipsClient() async {
            do {
                let messages = self.messages
                let client = MockData.createMockMessagesClient(fetchMessages: { messages })
                sut = client
                let store = MessagesStore()
                self.store = store
                await store.fetchMessages()

                await store.markAsRead(messageId: "missing")

                #expect(store.messages == messages)
                #expect(client.events == [.getMessages])
            }

            await expectStoreReleased()
        }

        @Test
        func messagesStoreDeallocatesAfterFetchAndMarkAsRead() async {
            do {
                let messages = self.messages
                sut = MockData.createMockMessagesClient(fetchMessages: { messages })
                await assertDeallocates({ MessagesStore() }) { store in
                    await store.fetchMessages()
                    await store.markAsRead(messageId: "unread-1")
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
