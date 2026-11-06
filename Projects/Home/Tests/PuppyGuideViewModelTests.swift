import AppStateContainer
import Foundation
import TestDependencies
import Testing
import hCore

@testable import Home

extension HomeDependencySuite {
    @MainActor
    final class PuppyGuideViewModelTests {
        private weak var sut: MockPuppyGuideClient?
        private weak var store: HomeStore?
        private weak var guideViewModel: PuppyGuideViewModel?
        private weak var articleViewModel: PuppyArticleViewModel?

        init() {
            resetContainer()
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        }

        private func expectReleased() async {
            Dependencies.shared.remove(for: PuppyGuideClient.self)
            resetContainer()
            await delay(0.0000001)

            #expect(guideViewModel == nil, "the guide view model must not outlive the test that created it")
            #expect(articleViewModel == nil, "the article view model must not outlive the test that created it")
            #expect(store == nil, "the home store must be released once the container is reset")
            #expect(sut == nil, "the mock client must not outlive its dependency registration")
        }

        private func resetContainer() {
            globalAppStateContainer.reset()
            globalAppStateContainer.clearPersistence()
        }

        private func makeListViewModel() -> PuppyGuideViewModel {
            let viewModel = PuppyGuideViewModel()
            guideViewModel = viewModel
            store = globalAppStateContainer.get(HomeStore.self)
            return viewModel
        }

        private func makeArticleViewModel(id: String = "feeding") -> PuppyArticleViewModel {
            let viewModel = PuppyArticleViewModel(id: id)
            articleViewModel = viewModel
            store = globalAppStateContainer.get(HomeStore.self)
            return viewModel
        }

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

        @Test
        func articleViewStateIsLoadingBeforeLoad() async {
            do {
                let client = MockData.createMockPuppyGuideClient()
                sut = client

                let viewModel = makeArticleViewModel()

                #expect(viewModel.id == "feeding")
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

                let viewModel = makeArticleViewModel(id: "walking")
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

                let viewModel = makeArticleViewModel(id: "unknown")
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
                #expect(store?.puppyGuideStory(id: "feeding")?.isRead == true)
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
                #expect(store?.puppyGuideStory(id: "feeding")?.rating == 5)
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
                let article = makeArticleViewModel(id: "walking")
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
