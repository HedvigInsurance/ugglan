import Combine
import Foundation
import UIKit
import hCore
import hCoreUI

@MainActor
final class FormFieldSearchViewModel: NSObject, ObservableObject {
    @Published var searchResults: [SingleSelectValue] = []
    @Published var processingState: ProcessingState = .success
    @Published var noResults: Bool = false
    @Published var searchSuggestedQuery: String?
    @Published var selectedValue: SingleSelectValue?
    @Published var isDebouncing: Bool = false
    @Published var searchText = ""
    private let stepId: String
    private let fieldId: String
    private let service: ClaimIntentService
    private var cancellables = Set<AnyCancellable>()
    let searchSubject = CurrentValueSubject<String, Never>("")

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = L10n.searchPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        searchController.searchBar.tintColor = .brand(.primaryText())

        return searchController
    }()

    let suggestedQuery: String?
    let modalTitle: String?
    let modalSubtitle: String?

    init(
        stepId: String,
        fieldId: String,
        suggestedQuery: String? = nil,
        modalTitle: String? = nil,
        modalSubtitle: String? = nil
    ) {
        self.stepId = stepId
        self.fieldId = fieldId
        self.suggestedQuery = suggestedQuery
        self.modalTitle = modalTitle
        self.modalSubtitle = modalSubtitle
        self.service = ClaimIntentService()
        super.init()
        setupSearchSubscription()
        searchSubject.send(suggestedQuery ?? "")
        searchText = suggestedQuery ?? ""
    }

    private var didActivate = false

    func activateSearch() {
        if !didActivate {
            // Activate without animation
            Task { [weak searchController] in
                if let suggestedQuery, !suggestedQuery.isEmpty {
                    searchController?.searchBar.text = suggestedQuery
                }
                await delay(0.1)
                UIView.performWithoutAnimation {
                    searchController?.isActive = true
                }
                // Small delay to ensure the search bar is in the hierarchy
                await delay(0.3)
                searchController?.searchBar.searchTextField.becomeFirstResponder()
                await delay(0.2)
                searchController?.searchBar.searchTextField.becomeFirstResponder()
            }
            didActivate = true
        }
    }

    private func setupSearchSubscription() {
        searchSubject
            .handleEvents(
                receiveOutput: { [weak self] value in
                    self?.searchText = value
                    if value.count > 1 {
                        self?.noResults = false
                        self?.isDebouncing = true
                    } else {
                        self?.searchResults = []
                    }
                }
            )
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter({ $0.count > 1 })
            .sink { [weak self] query in
                guard let self else { return }
                self.isDebouncing = false
                Task { [weak self] in
                    await self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            processingState = .success
            searchResults = []
            return
        }

        processingState = .loading
        do {
            let result = try await service.claimIntentFormFieldSearch(
                stepId: stepId,
                fieldId: fieldId,
                query: query
            )
            searchResults = result.options.map {
                SingleSelectValue(title: $0.title, subtitle: $0.subtitle, value: $0.value, imageUrl: $0.imageUrl)
            }
            searchSuggestedQuery = result.suggestedQuery
            processingState = .success
            if searchResults.isEmpty && !query.isEmpty {
                noResults = true
            }
        } catch {
            searchResults = []
            processingState = .error(errorMessage: error.localizedDescription)
        }
    }
}

extension FormFieldSearchViewModel: UISearchResultsUpdating {
    nonisolated func updateSearchResults(for searchController: UISearchController) {
        MainActor.assumeIsolated {
            let text = searchController.searchBar.text ?? ""
            searchSubject.send(text)
        }
    }
}
