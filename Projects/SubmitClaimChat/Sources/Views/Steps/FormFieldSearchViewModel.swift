import Combine
import Foundation
import UIKit
import hCore
import hCoreUI

@MainActor
final class FormFieldSearchViewModel: NSObject, ObservableObject {
    @Published var searchResults: [SingleSelectValue] = []
    @Published var isLoading: Bool = false
    @Published var searchInProgress: Bool = false {
        didSet {
            selectedValue = nil
        }
    }
    @Published var errorMessage: String?
    @Published var selectedValue: SingleSelectValue?

    private let stepId: String
    private let fieldId: String
    private let service: ClaimIntentService
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = L10n.searchPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        Task { [weak searchController] in
            await searchController?.searchBar.becomeFirstResponder()
        }
        return searchController
    }()

    init(stepId: String, fieldId: String) {
        self.stepId = stepId
        self.fieldId = fieldId
        self.service = ClaimIntentService()
        super.init()
        setupSearchSubscription()
    }

    private func setupSearchSubscription() {
        searchSubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                Task { [weak self] in
                    await self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            errorMessage = nil
            isLoading = false
            return
        }

        isLoading = true
        do {
            let options = try await service.claimIntentFormFieldSearch(
                stepId: stepId,
                fieldId: fieldId,
                query: query
            )
            searchResults = options.map {
                SingleSelectValue(title: $0.title, subtitle: $0.subtitle, value: $0.value)
            }
            errorMessage = nil
        } catch {
            searchResults = []
            errorMessage = error.localizedDescription
        }
        isLoading = false
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

    func willPresentSearchController(_: UISearchController) {
        updateColors()
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
