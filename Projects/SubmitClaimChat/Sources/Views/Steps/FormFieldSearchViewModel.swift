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
    @Published var searchInProgress: Bool = false {
        didSet {
            selectedValue = nil
        }
    }
    @Published var selectedValue: SingleSelectValue?
    @Published var isDebouncing: Bool = false

    private let stepId: String
    private let fieldId: String
    private let service: ClaimIntentService
    private var cancellables = Set<AnyCancellable>()
    let searchSubject = PassthroughSubject<String, Never>()

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = L10n.searchPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true

        return searchController
    }()

    private let suggestedQuery: String?

    init(stepId: String, fieldId: String, suggestedQuery: String? = nil) {
        self.stepId = stepId
        self.fieldId = fieldId
        self.suggestedQuery = suggestedQuery
        self.service = ClaimIntentService()
        super.init()
        setupSearchSubscription()
    }

    private var didActivate = false

    func activateSearch() {
        if !didActivate {
            // Activate without animation
            Task {
                await delay(0.1)
                UIView.performWithoutAnimation {
                    searchController.isActive = true
                }

                if let suggestedQuery, !suggestedQuery.isEmpty {
                    searchController.searchBar.text = suggestedQuery
                }

                // Small delay to ensure the search bar is in the hierarchy
                await delay(0.3)
                searchController.searchBar.searchTextField.becomeFirstResponder()
                await delay(0.2)
                searchController.searchBar.searchTextField.becomeFirstResponder()
            }
            didActivate = true
        }
    }

    private func setupSearchSubscription() {
        searchSubject
            .handleEvents(
                receiveOutput: { [weak self] value in
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
            let options = try await service.claimIntentFormFieldSearch(
                stepId: stepId,
                fieldId: fieldId,
                query: query
            )
            searchResults = options.map {
                SingleSelectValue(title: $0.title, subtitle: $0.subtitle, value: $0.value)
            }
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
            searchInProgress = searchController.isActive
            searchSubject.send(text)
            updateColors()
        }
    }
}

extension FormFieldSearchViewModel: UISearchControllerDelegate {
    func didPresentSearchController(_: UISearchController) {
        updateColors()
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        // Disable animations during presentation
        UIView.performWithoutAnimation {
            updateColors()
        }
    }

    func updateColors() {
        let button = searchController.searchBar.subviews.first?.subviews.last?.subviews.last as? UIButton
        let hColor = hTextColor.Opaque.primary
        let color = UIColor(
            light: hColor.colorFor(.light, .base).color.uiColor(),
            dark: hColor.colorFor(.dark, .base).color.uiColor()
        )
        button?.setTitleColor(color, for: .normal)
    }
}
