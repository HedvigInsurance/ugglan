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
    let id: String
    @ObservationIgnored private let store: HomeStore = globalAppStateContainer.get()

    init(id: String) {
        self.id = id
    }

    var story: PuppyGuideStory? { store.puppyGuideStory(id: id) }

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
        await store.markPuppyGuideStoryAsRead(id: id)
    }

    func rate(_ rating: Int) async {
        await store.ratePuppyGuideStory(name: id, rating: rating)
    }
}
