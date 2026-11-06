import AppStateContainer
import Foundation
import TestDependencies
import Testing
import hCore

@testable import Home

enum PuppyGuideTestError: Error {
    case failed
}

extension HomeDependencySuite {
    @MainActor
    final class HomeStorePuppyGuideTests {
        private weak var sut: MockPuppyGuideClient?
        private weak var store: HomeStore?

        init() {
            resetContainer()
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        }

        private func expectReleased() async {
            Dependencies.shared.remove(for: PuppyGuideClient.self)
            resetContainer()
            await delay(0.0000001)

            #expect(store == nil, "the home store must not outlive the test that created it")
            #expect(sut == nil, "the mock client must not outlive its dependency registration")
        }

        private func resetContainer() {
            globalAppStateContainer.reset()
            globalAppStateContainer.clearPersistence()
        }

        private func makeStore() -> HomeStore {
            let store = HomeStore()
            self.store = store
            return store
        }

        private func makeLoadedStore(_ client: MockPuppyGuideClient) async -> HomeStore {
            let store = makeStore()
            await store.fetchPuppyGuideIfNeeded()
            client.events.removeAll()
            return store
        }

        @Test
        func fetchPuppyGuideIfNeededSuccess() async {
            do {
                let expected = PuppyGuide.mock()
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: { expected })
                sut = client

                let store = makeStore()
                #expect(store.puppyGuideState == .notLoaded)
                await store.fetchPuppyGuideIfNeeded()

                #expect(store.puppyGuideState == .loaded(expected))
                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func fetchPuppyGuideIfNeededSetsLoadingWhileInFlight() async {
            do {
                var stateDuringCall: LoadState<PuppyGuide>?
                weak var weakStore: HomeStore?
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    stateDuringCall = weakStore?.puppyGuideState
                    return .mock()
                })
                sut = client

                let store = makeStore()
                weakStore = store
                await store.fetchPuppyGuideIfNeeded()

                #expect(stateDuringCall == .loading)
                #expect(store.puppyGuideState == .loaded(.mock()))
            }

            await expectReleased()
        }

        @Test
        func fetchPuppyGuideIfNeededAfterSuccessSkipsClient() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = makeStore()
                await store.fetchPuppyGuideIfNeeded()
                await store.fetchPuppyGuideIfNeeded()

                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func fetchPuppyGuideIfNeededConcurrentCallsFetchOnce() async {
            do {
                let expected = PuppyGuide.mock()
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    await delay(0.05)
                    return expected
                })
                sut = client

                let store = makeStore()
                async let first: Void = store.fetchPuppyGuideIfNeeded()
                async let second: Void = store.fetchPuppyGuideIfNeeded()
                _ = await (first, second)

                #expect(client.events == [.getPuppyGuide])
                #expect(store.puppyGuideState == .loaded(expected))
            }

            await expectReleased()
        }

        @Test
        func fetchPuppyGuideIfNeededFailure() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    throw PuppyGuideTestError.failed
                })
                sut = client

                let store = makeStore()
                await store.fetchPuppyGuideIfNeeded()

                #expect(store.puppyGuideState == .failed(errorMessage: L10n.General.errorBody))
                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func fetchPuppyGuideIfNeededNoGuideFails() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: { nil })
                sut = client

                let store = makeStore()
                await store.fetchPuppyGuideIfNeeded()

                #expect(store.puppyGuideState == .failed(errorMessage: L10n.General.errorBody))
                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func fetchPuppyGuideIfNeededAfterFailureRetries() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    throw PuppyGuideTestError.failed
                })
                sut = client

                let store = makeStore()
                await store.fetchPuppyGuideIfNeeded()
                #expect(store.puppyGuideState == .failed(errorMessage: L10n.General.errorBody))

                var stateDuringRetry: LoadState<PuppyGuide>?
                weak let weakStore = store
                let expected = PuppyGuide.mock()
                client.fetchPuppyGuide = {
                    stateDuringRetry = weakStore?.puppyGuideState
                    return expected
                }
                await store.fetchPuppyGuideIfNeeded()

                #expect(stateDuringRetry == .loading)
                #expect(store.puppyGuideState == .loaded(expected))
                #expect(client.events == [.getPuppyGuide, .getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadSuccess() async {
            await recordingErrors {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = await makeLoadedStore(client)
                await store.markPuppyGuideStoryAsRead(id: "feeding")

                let story = try #require(store.puppyGuideStory(id: "feeding"))
                #expect(story.isRead)
                #expect(story.showsAsRead)
                #expect(store.puppyGuideStory(id: "walking")?.isRead == false)
                #expect(client.events == [.setStoryRead(name: "feeding")])
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadUpdatesLocallyBeforeClientCall() async {
            do {
                var isReadDuringCall: Bool?
                weak var weakStore: HomeStore?
                let client = MockData.createMockPuppyGuideClient(setStoryRead: { name in
                    isReadDuringCall = weakStore?.puppyGuideStory(id: name)?.isRead
                })
                sut = client

                let store = await makeLoadedStore(client)
                weakStore = store
                await store.markPuppyGuideStoryAsRead(id: "feeding")

                #expect(isReadDuringCall == true)
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadTwiceCallsClientOnce() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = await makeLoadedStore(client)
                await store.markPuppyGuideStoryAsRead(id: "feeding")
                await store.markPuppyGuideStoryAsRead(id: "feeding")

                #expect(client.events == [.setStoryRead(name: "feeding")])
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadAlreadyReadSkipsClient() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    .mock(stories: [.mock(name: "feeding", isRead: true)])
                })
                sut = client

                let store = await makeLoadedStore(client)
                await store.markPuppyGuideStoryAsRead(id: "feeding")

                #expect(store.puppyGuideStory(id: "feeding")?.isRead == true)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadUnknownStorySkipsClient() async {
            do {
                let loaded = PuppyGuide.mock()
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: { loaded })
                sut = client

                let store = await makeLoadedStore(client)
                await store.markPuppyGuideStoryAsRead(id: "unknown")

                #expect(store.puppyGuideState == .loaded(loaded))
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadBeforeLoadSkipsClient() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = makeStore()
                await store.markPuppyGuideStoryAsRead(id: "feeding")

                #expect(store.puppyGuideState == .notLoaded)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadFailureRevertsLocalUpdate() async {
            do {
                let client = MockData.createMockPuppyGuideClient(setStoryRead: { _ in
                    throw PuppyGuideError.engagementNotSaved
                })
                sut = client

                let store = await makeLoadedStore(client)
                await store.markPuppyGuideStoryAsRead(id: "feeding")

                #expect(store.puppyGuideStory(id: "feeding")?.isRead == false)
                #expect(client.events == [.setStoryRead(name: "feeding")])
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStorySuccess() async {
            await recordingErrors {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = await makeLoadedStore(client)
                await store.ratePuppyGuideStory(id: "walking", rating: 4)

                let story = try #require(store.puppyGuideStory(id: "walking"))
                #expect(story.rating == 4)
                #expect(story.isRead == false)
                #expect(story.showsAsRead)
                #expect(store.puppyGuideStory(id: "feeding")?.rating == nil)
                #expect(client.events == [.setStoryRating(name: "walking", rating: 4)])
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStoryUpdatesLocallyBeforeClientCall() async {
            do {
                var ratingDuringCall: Int?
                weak var weakStore: HomeStore?
                let client = MockData.createMockPuppyGuideClient(setStoryRating: { name, _ in
                    ratingDuringCall = weakStore?.puppyGuideStory(id: name)?.rating
                })
                sut = client

                let store = await makeLoadedStore(client)
                weakStore = store
                await store.ratePuppyGuideStory(id: "walking", rating: 3)

                #expect(ratingDuringCall == 3)
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStoryChangedRatingCallsClientAgain() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = await makeLoadedStore(client)
                await store.ratePuppyGuideStory(id: "walking", rating: 4)
                await store.ratePuppyGuideStory(id: "walking", rating: 2)

                #expect(store.puppyGuideStory(id: "walking")?.rating == 2)
                #expect(
                    client.events == [
                        .setStoryRating(name: "walking", rating: 4),
                        .setStoryRating(name: "walking", rating: 2),
                    ]
                )
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStoryUnchangedRatingSkipsClient() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    .mock(stories: [.mock(name: "walking", rating: 5)])
                })
                sut = client

                let store = await makeLoadedStore(client)
                await store.ratePuppyGuideStory(id: "walking", rating: 5)

                #expect(store.puppyGuideStory(id: "walking")?.rating == 5)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStoryUnknownStorySkipsClient() async {
            do {
                let loaded = PuppyGuide.mock()
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: { loaded })
                sut = client

                let store = await makeLoadedStore(client)
                await store.ratePuppyGuideStory(id: "unknown", rating: 3)

                #expect(store.puppyGuideState == .loaded(loaded))
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStoryBeforeLoadSkipsClient() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = makeStore()
                await store.ratePuppyGuideStory(id: "walking", rating: 3)

                #expect(store.puppyGuideState == .notLoaded)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStoryFailureRevertsLocalUpdate() async {
            do {
                let client = MockData.createMockPuppyGuideClient(
                    fetchPuppyGuide: { .mock(stories: [.mock(name: "walking", rating: 3)]) },
                    setStoryRating: { _, _ in
                        throw PuppyGuideError.engagementNotSaved
                    }
                )
                sut = client

                let store = await makeLoadedStore(client)
                await store.ratePuppyGuideStory(id: "walking", rating: 1)

                #expect(store.puppyGuideStory(id: "walking")?.rating == 3)
                #expect(client.events == [.setStoryRating(name: "walking", rating: 1)])
            }

            await expectReleased()
        }
    }
}
