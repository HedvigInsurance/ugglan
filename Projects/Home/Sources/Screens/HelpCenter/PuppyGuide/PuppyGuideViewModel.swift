import AppStateContainer
import Foundation
import hCore

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
