import AppStateContainer
import Foundation
import hCore

/// The guide is loaded once into `HomeStore` (started by the Help Center entry); this only reads it, and loads it
/// again only when the member retries after a failure.
@MainActor
@Observable
final class PuppyGuideViewModel {
    @ObservationIgnored private let store: HomeStore = globalAppStateContainer.get()

    var puppyGuide: PuppyGuide? { store.puppyGuideState.value }

    var viewState: ProcessingState { store.puppyGuideState.processingState }

    func load() async {
        await store.fetchPuppyGuideIfNeeded()
    }
}

@MainActor
@Observable
final class PuppyArticleViewModel {
    let storyName: String
    @ObservationIgnored private let store: HomeStore = globalAppStateContainer.get()

    init(storyName: String) {
        self.storyName = storyName
    }

    var story: PuppyGuideStory? { store.puppyGuideStory(named: storyName) }

    var viewState: ProcessingState {
        // The guide loaded but no longer has this story.
        if case .loaded = store.puppyGuideState, story == nil {
            return .error(errorMessage: L10n.General.errorBody)
        }
        return store.puppyGuideState.processingState
    }

    func load() async {
        await store.fetchPuppyGuideIfNeeded()
    }

    func markAsRead() async {
        await store.markPuppyGuideStoryAsRead(name: storyName)
    }

    func rate(_ rating: Int) async {
        await store.ratePuppyGuideStory(name: storyName, rating: rating)
    }
}
