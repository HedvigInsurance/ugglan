import AppStateContainer
import Combine
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
class HelpCenterStartViewModel: NSObject {
    var helpCenterModel: HelpCenterFAQModel?
    @ObservationIgnored var didSetInitialSearchAppearance = false
    var quickActions: [QuickAction] = []
    // search part
    var searchResultsQuestions: [FAQModel] = []
    var searchResultsQuickActions: [QuickAction] = []
    var searchInProgress = false
    @ObservationIgnored private var allQuestions: [FAQModel] = []
    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []
    @ObservationIgnored lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = L10n.searchPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    override init() {
        super.init()
        let store: HomeStore = globalAppStateContainer.get()
        store.publisher(for: \.quickActions)
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] quickActions in
                self?.quickActions = quickActions
            }
            .store(in: &cancellables)
        store.publisher(for: \.helpCenterFAQModel)
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self, weak store] helpCenterFaqModel in
                self?.helpCenterModel = helpCenterFaqModel
                self?.allQuestions = store?.getAllFAQ() ?? []
            }
            .store(in: &cancellables)
        Task { await store.fetchFAQ() }
    }

    func startSearch(for inputText: String) {
        if !inputText.isEmpty {
            let trimmedQuery: String =
                inputText.lowercased().trimmingCharacters(in: .whitespaces)
            let questions = searchInQuestionsByQuery(query: trimmedQuery)
            let actions = searchInQuickActionsByQuery(query: trimmedQuery)
            searchResultsQuestions = questions
            searchResultsQuickActions = actions
        } else {
            searchResultsQuestions = allQuestions
            searchResultsQuickActions = quickActions
        }
    }

    private func searchInQuestionsByQuery(query: String) -> [FAQModel] {
        allQuestions.filter {
            $0.answer.lowercased().contains(query) || $0.question.lowercased().contains(query)
        }
    }

    private func searchInQuickActionsByQuery(query: String) -> [QuickAction] {
        let query = query.lowercased()
        return quickActions.filter {
            $0.displayTitle.lowercased().contains(query) || $0.displaySubtitle.lowercased().contains(query)
        }
    }
}

extension HelpCenterStartViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        withAnimation {
            searchInProgress = searchController.isActive
            startSearch(for: searchController.searchBar.text ?? "")
        }
        updateColors()
    }
}

extension HelpCenterStartViewModel: UISearchControllerDelegate {
    func didPresentSearchController(_: UISearchController) {
        updateColors()
    }

    func willPresentSearchController(_: UISearchController) {
        updateColors()
    }

    func updateColors() {
        let button = searchController.searchBar.subviews.first?.subviews.last?.subviews.last as? UIButton
        let color = hTextColor.Opaque.primary.uiColor()
        button?.setTitleColor(color, for: .normal)
    }
}
