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

        // Test bodies are scoped in a do block or recordingErrors so their locals are released before this check.
        private func expectReleased() async {
            Dependencies.shared.remove(for: PuppyGuideClient.self)
            resetContainer()
            await delay(0.0000001)

            #expect(store == nil, "the home store must not outlive the test that created it")
            #expect(sut == nil, "the mock client must not outlive its dependency registration")
        }

        // reset before clearing: it cancels the debounced snapshot write that would otherwise land after the wipe
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

        // MARK: - fetchPuppyGuideIfNeeded

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

        // MARK: - markPuppyGuideStoryAsRead

        @Test
        func markPuppyGuideStoryAsReadSuccess() async {
            await recordingErrors {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = await makeLoadedStore(client)
                await store.markPuppyGuideStoryAsRead(name: "feeding")

                let story = try #require(store.puppyGuideStory(named: "feeding"))
                #expect(story.isRead)
                #expect(story.showsAsRead)
                #expect(store.puppyGuideStory(named: "walking")?.isRead == false)
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
                    isReadDuringCall = weakStore?.puppyGuideStory(named: name)?.isRead
                })
                sut = client

                let store = await makeLoadedStore(client)
                weakStore = store
                await store.markPuppyGuideStoryAsRead(name: "feeding")

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
                await store.markPuppyGuideStoryAsRead(name: "feeding")
                await store.markPuppyGuideStoryAsRead(name: "feeding")

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
                await store.markPuppyGuideStoryAsRead(name: "feeding")

                #expect(store.puppyGuideStory(named: "feeding")?.isRead == true)
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
                await store.markPuppyGuideStoryAsRead(name: "unknown")

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
                await store.markPuppyGuideStoryAsRead(name: "feeding")

                #expect(store.puppyGuideState == .notLoaded)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func markPuppyGuideStoryAsReadFailureKeepsLocalUpdate() async {
            do {
                let client = MockData.createMockPuppyGuideClient(setStoryRead: { _ in
                    throw PuppyGuideError.engagementNotSaved
                })
                sut = client

                let store = await makeLoadedStore(client)
                await store.markPuppyGuideStoryAsRead(name: "feeding")

                #expect(store.puppyGuideStory(named: "feeding")?.isRead == true)
                #expect(client.events == [.setStoryRead(name: "feeding")])
            }

            await expectReleased()
        }

        // MARK: - ratePuppyGuideStory

        @Test
        func ratePuppyGuideStorySuccess() async {
            await recordingErrors {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let store = await makeLoadedStore(client)
                await store.ratePuppyGuideStory(name: "walking", rating: 4)

                let story = try #require(store.puppyGuideStory(named: "walking"))
                #expect(story.rating == 4)
                #expect(story.isRead == false)
                #expect(story.showsAsRead)
                #expect(store.puppyGuideStory(named: "feeding")?.rating == nil)
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
                    ratingDuringCall = weakStore?.puppyGuideStory(named: name)?.rating
                })
                sut = client

                let store = await makeLoadedStore(client)
                weakStore = store
                await store.ratePuppyGuideStory(name: "walking", rating: 3)

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
                await store.ratePuppyGuideStory(name: "walking", rating: 4)
                await store.ratePuppyGuideStory(name: "walking", rating: 2)

                #expect(store.puppyGuideStory(named: "walking")?.rating == 2)
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
                await store.ratePuppyGuideStory(name: "walking", rating: 5)

                #expect(store.puppyGuideStory(named: "walking")?.rating == 5)
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
                await store.ratePuppyGuideStory(name: "unknown", rating: 3)

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
                await store.ratePuppyGuideStory(name: "walking", rating: 3)

                #expect(store.puppyGuideState == .notLoaded)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func ratePuppyGuideStoryFailureKeepsLocalUpdate() async {
            do {
                let client = MockData.createMockPuppyGuideClient(setStoryRating: { _, _ in
                    throw PuppyGuideError.engagementNotSaved
                })
                sut = client

                let store = await makeLoadedStore(client)
                await store.ratePuppyGuideStory(name: "walking", rating: 1)

                #expect(store.puppyGuideStory(named: "walking")?.rating == 1)
                #expect(client.events == [.setStoryRating(name: "walking", rating: 1)])
            }

            await expectReleased()
        }
    }

    @MainActor
    final class PuppyGuideViewModelTests {
        private weak var sut: MockPuppyGuideClient?
        private weak var store: HomeStore?
        private weak var listViewModel: PuppyGuideViewModel?
        private weak var articleViewModel: PuppyArticleViewModel?

        init() {
            resetContainer()
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        }

        // Test bodies are scoped in a do block so their locals are released before this check. The view models read
        // the HomeStore from globalAppStateContainer, so resetting it is what releases the store.
        private func expectReleased() async {
            Dependencies.shared.remove(for: PuppyGuideClient.self)
            resetContainer()
            await delay(0.0000001)

            #expect(listViewModel == nil, "the list view model must not outlive the test that created it")
            #expect(articleViewModel == nil, "the article view model must not outlive the test that created it")
            #expect(store == nil, "the home store must be released once the container is reset")
            #expect(sut == nil, "the mock client must not outlive its dependency registration")
        }

        // reset before clearing: it cancels the debounced snapshot write that would otherwise land after the wipe
        private func resetContainer() {
            globalAppStateContainer.reset()
            globalAppStateContainer.clearPersistence()
        }

        private func makeListViewModel() -> PuppyGuideViewModel {
            let viewModel = PuppyGuideViewModel()
            listViewModel = viewModel
            store = globalAppStateContainer.get(HomeStore.self)
            return viewModel
        }

        private func makeArticleViewModel(storyName: String = "feeding") -> PuppyArticleViewModel {
            let viewModel = PuppyArticleViewModel(storyName: storyName)
            articleViewModel = viewModel
            store = globalAppStateContainer.get(HomeStore.self)
            return viewModel
        }

        // MARK: - PuppyGuideViewModel

        @Test
        func listViewStateIsLoadingBeforeLoad() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeListViewModel()

                #expect(viewModel.viewState == .loading)
                #expect(viewModel.puppyGuide == nil)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func listLoadSuccess() async {
            do {
                let expected = PuppyGuide.mock()
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: { expected })
                sut = client

                let viewModel = makeListViewModel()
                await viewModel.load()

                #expect(viewModel.viewState == .success)
                #expect(viewModel.puppyGuide == expected)
                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func listLoadFailure() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    throw PuppyGuideTestError.failed
                })
                sut = client

                let viewModel = makeListViewModel()
                await viewModel.load()

                #expect(viewModel.viewState == .error(errorMessage: L10n.General.errorBody))
                #expect(viewModel.puppyGuide == nil)
            }

            await expectReleased()
        }

        @Test
        func listLoadRetryAfterFailureSuccess() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    throw PuppyGuideTestError.failed
                })
                sut = client

                let viewModel = makeListViewModel()
                await viewModel.load()
                #expect(viewModel.viewState.isError)

                client.fetchPuppyGuide = { .mock() }
                await viewModel.load()

                #expect(viewModel.viewState == .success)
                #expect(client.events == [.getPuppyGuide, .getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func listLoadTwiceFetchesOnce() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeListViewModel()
                await viewModel.load()
                await viewModel.load()

                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        // MARK: - PuppyArticleViewModel

        @Test
        func articleViewStateIsLoadingBeforeLoad() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeArticleViewModel()

                #expect(viewModel.storyName == "feeding")
                #expect(viewModel.viewState == .loading)
                #expect(viewModel.story == nil)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func articleLoadSuccess() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeArticleViewModel(storyName: "walking")
                await viewModel.load()

                #expect(viewModel.viewState == .success)
                #expect(viewModel.story == .mock(name: "walking", categories: ["Training"]))
                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func articleLoadUnknownStoryError() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeArticleViewModel(storyName: "unknown")
                await viewModel.load()
                await viewModel.markAsRead()
                await viewModel.rate(4)

                #expect(viewModel.viewState == .error(errorMessage: L10n.General.errorBody))
                #expect(viewModel.story == nil)
                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func articleLoadFailureError() async {
            do {
                let client = MockData.createMockPuppyGuideClient(fetchPuppyGuide: {
                    throw PuppyGuideTestError.failed
                })
                sut = client

                let viewModel = makeArticleViewModel()
                await viewModel.load()

                #expect(viewModel.viewState == .error(errorMessage: L10n.General.errorBody))
                #expect(viewModel.story == nil)
            }

            await expectReleased()
        }

        @Test
        func articleMarkAsReadForwardsToStore() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeArticleViewModel()
                await viewModel.load()
                await viewModel.markAsRead()

                #expect(viewModel.story?.isRead == true)
                #expect(store?.puppyGuideStory(named: "feeding")?.isRead == true)
                #expect(client.events == [.getPuppyGuide, .setStoryRead(name: "feeding")])
            }

            await expectReleased()
        }

        @Test
        func articleRateForwardsToStore() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeArticleViewModel()
                await viewModel.load()
                await viewModel.rate(5)

                #expect(viewModel.story?.rating == 5)
                #expect(store?.puppyGuideStory(named: "feeding")?.rating == 5)
                #expect(client.events == [.getPuppyGuide, .setStoryRating(name: "feeding", rating: 5)])
            }

            await expectReleased()
        }

        @Test
        func articleMarkAsReadAndRateBeforeLoadSkipClient() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeArticleViewModel()
                await viewModel.markAsRead()
                await viewModel.rate(3)

                #expect(viewModel.story == nil)
                #expect(client.events.isEmpty)
            }

            await expectReleased()
        }

        @Test
        func listThenArticleLoadFetchesOnce() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let list = makeListViewModel()
                await list.load()
                let article = makeArticleViewModel()
                await article.load()

                #expect(list.viewState == .success)
                #expect(article.viewState == .success)
                #expect(client.events == [.getPuppyGuide])
            }

            await expectReleased()
        }

        @Test
        func articleChangesShowInList() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let list = makeListViewModel()
                await list.load()
                let article = makeArticleViewModel(storyName: "walking")
                await article.load()
                await article.rate(2)

                let walking = list.puppyGuide?.stories.first { $0.name == "walking" }
                #expect(walking?.rating == 2)
                #expect(walking?.showsAsRead == true)
                #expect(client.events == [.getPuppyGuide, .setStoryRating(name: "walking", rating: 2)])
            }

            await expectReleased()
        }
    }
}
