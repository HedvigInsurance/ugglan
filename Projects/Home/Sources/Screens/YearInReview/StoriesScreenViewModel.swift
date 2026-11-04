import Kingfisher
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
final class StoriesLoaderViewModel {
    @ObservationIgnored @Inject private var client: YearInReviewClient
    var viewState: ProcessingState = .loading
    private(set) var stories: [Story]?

    func loadStories() async {
        viewState = .loading
        do {
            let stories = try await client.getStories()
            // The player needs at least one story to show
            guard !stories.isEmpty else {
                viewState = .error(errorMessage: L10n.General.errorBody)
                return
            }
            self.stories = stories
            viewState = .success
        } catch {
            viewState = .error(errorMessage: error.localizedDescription)
        }
    }
}

/// Which parts of the current story are visible; they fade in one after another
struct StoryReveal {
    var image = false
    var title = false
    var text = false
    var thankYouButton = false
}

@MainActor
@Observable
class StoriesScreenViewModel {
    let stories: [Story]
    private(set) var currentIndex = 0
    private(set) var reveal = StoryReveal()
    /// How full each story's progress bar is, from 0 to 1
    private(set) var barProgress: [Double]
    /// True while a finger is held on the story; freezes progress, content reveal and GIFs
    private(set) var isPaused = false

    @ObservationIgnored private var touchStartDate: Date?
    /// Holds playback like a pause while the bars animate towards the next story
    @ObservationIgnored private var isSwitchingStory = false

    /// Pillows cycled through as the bottom background, one per story
    private static let pillows: [PillowType] = [
        .home, .rental, .villa, .homeOwner, .car, .dog, .cat, .accident, .student, .vacationHome,
    ]

    init(stories: [Story]) {
        self.stories = stories
        self.barProgress = Array(repeating: 0, count: stories.count)
        ImagePrefetcher(urls: stories.map(\.imageUrl), options: [.targetCache(ImageCache.default)]).start()
    }

    var currentStory: Story {
        stories[currentIndex]
    }

    var currentPillow: PillowType {
        Self.pillows[currentIndex % Self.pillows.count]
    }

    private var isOnLastStory: Bool {
        currentIndex == stories.count - 1
    }

    // MARK: Playback

    /// Reveals the current story's content while filling its progress bar, then moves on to the next story.
    /// Runs in the screen's `.task(id:)`, which cancels it whenever the story changes.
    func playCurrentStory() async {
        async let revealing: Void = revealContent()
        async let progressing: Void = fillProgress()
        do {
            try await revealing
            try await progressing
        } catch {
            return  // Cancelled
        }
        await goToStory(at: currentIndex + 1)
    }

    private func revealContent() async throws {
        try await sleep(for: StoryConstants.Reveal.imageDelay)
        withAnimation { reveal.image = true }

        try await sleep(for: StoryConstants.Reveal.stepDelay)
        withAnimation { reveal.title = true }

        try await sleep(for: StoryConstants.Reveal.stepDelay)
        withAnimation { reveal.text = true }

        guard isOnLastStory else { return }
        try await sleep(for: StoryConstants.Reveal.thankYouButtonDelay)
        withAnimation { reveal.thankYouButton = true }
    }

    private func fillProgress() async throws {
        let increment = StoryConstants.tickInterval / StoryConstants.storyDuration
        while barProgress[currentIndex] < 1 {
            try await sleep(for: StoryConstants.tickInterval)
            barProgress[currentIndex] = min(barProgress[currentIndex] + increment, 1)
        }
    }

    /// Like `Task.sleep`, but time spent paused or switching story does not count towards `duration`
    private func sleep(for duration: TimeInterval) async throws {
        var remaining = duration
        while remaining > 0 {
            let tick = min(StoryConstants.tickInterval, remaining)
            try await Task.sleep(for: .seconds(tick))
            if !isPaused && !isSwitchingStory {
                remaining -= tick
            }
        }
    }

    /// Animates the bars one at a time before switching: going forward the current bar fills up,
    /// going back the current bar empties and then the previous one does, so that story starts over.
    /// Does nothing past either end, or while already switching.
    private func goToStory(at index: Int) async {
        guard stories.indices.contains(index), !isSwitchingStory else { return }
        isSwitchingStory = true
        defer { isSwitchingStory = false }

        let isGoingForward = index > currentIndex
        await animateBar(at: currentIndex, to: isGoingForward ? 1 : 0)
        if !isGoingForward {
            await animateBar(at: index, to: 0)
        }

        // Reset before switching so the new story's views start hidden
        reveal = StoryReveal()
        withAnimation {
            currentIndex = index
        }
    }

    private func animateBar(at index: Int, to value: Double) async {
        guard barProgress[index] != value else { return }
        withAnimation(.easeInOut(duration: StoryConstants.barTransitionDuration)) {
            barProgress[index] = value
        }
        try? await Task.sleep(for: .seconds(StoryConstants.barTransitionDuration))
    }

    // MARK: Touch handling

    func touchBegan() {
        guard touchStartDate == nil else { return }
        touchStartDate = Date()
        isPaused = true
    }

    /// A quick tap switches story, a hold only pauses until the finger lifts
    func touchEnded(isOnLeadingHalf: Bool) {
        defer {
            touchStartDate = nil
            isPaused = false
        }
        guard let touchStartDate, Date().timeIntervalSince(touchStartDate) < StoryConstants.tapThreshold else {
            return
        }
        let index = isOnLeadingHalf ? currentIndex - 1 : currentIndex + 1
        Task { await goToStory(at: index) }
    }
}
