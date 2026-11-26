import Foundation
import TestDependencies
import Testing
import hCore

@testable import Home

extension HomeDependencySuite {
    /// Nested in `HomeDependencySuite` because `open(_:)` resolves `URLOpener` from `Dependencies.shared`.
    @MainActor
    final class StoriesScreenViewModelActionTests {
        private weak var vm: StoriesScreenViewModel?
        private weak var opener: MockURLOpener?

        private func makeViewModel(storyCount: Int = 2) throws -> StoriesScreenViewModel {
            let action = StoryAction(title: "Open", url: try #require(URL(string: "https://hedvig.com/action")))
            let stories = (0..<storyCount)
                .map { Story(id: "\($0)", title: "title \($0)", description: "text", fileUrl: nil, action: action) }
            let viewModel = StoriesScreenViewModel(stories: stories)
            vm = viewModel
            return viewModel
        }

        /// The opener stays suspended in `open` until `finishOpening()`, so the paused state can be observed
        private func makeSuspendingOpener() -> MockURLOpener {
            let mockOpener = MockData.createMockURLOpener()
            mockOpener.suspendsOpening = true
            opener = mockOpener
            return mockOpener
        }

        /// Longer than the tap's bar animation, so a story switch would have finished by then
        private func waitPastStorySwitch() async {
            await delay(StoryConstants.barTransitionDuration * 3)
        }

        private func expectReleased() async {
            Dependencies.shared.remove(for: URLOpener.self)
            // A tap starts an unstructured Task holding the view model until the bar animation ends.
            await waitUntil(description: "the view model is released after the test") { self.vm == nil }
            #expect(opener == nil, "the mock opener must not outlive its dependency registration")
        }

        @Test
        func openPausesUntilTheUrlIsOpened() async {
            await recordingErrors {
                let mockOpener = makeSuspendingOpener()
                let viewModel = try makeViewModel()
                let action = try #require(viewModel.currentStory.action)

                #expect(!viewModel.isPaused)
                let opening = Task { await viewModel.open(action) }
                await waitUntil(description: "the action URL is being opened") { !mockOpener.openedURLs.isEmpty }

                #expect(viewModel.isPaused)
                #expect(mockOpener.openedURLs == [action.url])

                mockOpener.finishOpening()
                await opening.value
                #expect(!viewModel.isPaused)
            }

            await expectReleased()
        }

        @Test
        func quickTapWhileOpeningResumesWithoutSwitchingStory() async {
            await recordingErrors {
                let mockOpener = makeSuspendingOpener()
                let viewModel = try makeViewModel()
                let action = try #require(viewModel.currentStory.action)

                let opening = Task { await viewModel.open(action) }
                await waitUntil(description: "the action URL is being opened") { !mockOpener.openedURLs.isEmpty }
                viewModel.touchBegan()
                viewModel.touchEnded(isOnLeadingHalf: false)

                #expect(!viewModel.isPaused)
                await waitPastStorySwitch()
                #expect(viewModel.currentIndex == 0)
                #expect(viewModel.barProgress == [0, 0], "no bar animation towards the next story should start")

                mockOpener.finishOpening()
                await opening.value
            }

            await expectReleased()
        }

        @Test
        func quickTapWithoutOpenSwitchesToNextStory() async {
            await recordingErrors {
                let viewModel = try makeViewModel()

                viewModel.touchBegan()
                #expect(viewModel.isPaused)
                viewModel.touchEnded(isOnLeadingHalf: false)

                #expect(!viewModel.isPaused)
                await waitUntil(description: "the tap moves to the next story") { viewModel.currentIndex == 1 }
                #expect(viewModel.currentIndex == 1)
            }

            await expectReleased()
        }
    }
}
