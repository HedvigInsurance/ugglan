import ChangeMileageCore
import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
public class ChangeMileageViewModel {
    @ObservationIgnored private let service = ChangeMileageService()

    let contract: ChangeMileageContract
    /// Loading the mileage options; an error carries the backend's message when it explains why.
    var viewState: ProcessingState = .loading
    var commitState: ProcessingState = .loading
    /// False when the backend explained why the mileage can't be changed, since asking again gives the same answer.
    private(set) var canRetryIntent = true

    private(set) var intent: ChangeMileageIntent?
    private(set) var selectedQuote: MileageQuote?

    var quotes: [MileageQuote] { intent?.quotes ?? [] }
    var currentQuote: MileageQuote? { quotes.first(where: \.isCurrent) }
    var isCurrentSelected: Bool { selectedQuote == nil || selectedQuote == currentQuote }

    /// `quotes` are sorted ascending by mileage, so an earlier index is a lower band than today's.
    var isLowerThanCurrentSelected: Bool {
        guard let selectedQuote, let selectedIndex = quotes.firstIndex(of: selectedQuote),
            let currentIndex = quotes.firstIndex(where: \.isCurrent)
        else { return false }
        return selectedIndex < currentIndex
    }

    public init(contract: ChangeMileageContract) {
        self.contract = contract
        fetchIntent()
    }

    func fetchIntent() {
        withAnimation { viewState = .loading }
        Task { [weak self] in
            guard let self else { return }
            do {
                let intent = try await service.createIntent(contractId: contract.contractId)
                guard let current = intent.quotes.first(where: \.isCurrent) else {
                    throw ChangeMileageError.somethingWentWrong
                }
                self.intent = intent
                selectedQuote = current
                withAnimation { viewState = .success }
            } catch {
                if case .userError = error as? ChangeMileageError {
                    canRetryIntent = false
                } else {
                    canRetryIntent = true
                }
                withAnimation { viewState = .error(errorMessage: error.localizedDescription) }
            }
        }
    }

    func select(quoteId: String) {
        selectedQuote = quotes.first(where: { $0.id == quoteId }) ?? selectedQuote
    }

    func commit() {
        guard let quote = selectedQuote, !quote.isCurrent else { return }
        withAnimation { commitState = .loading }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await service.commitIntent(quoteId: quote.id)
                withAnimation { commitState = .success }
            } catch {
                withAnimation { commitState = .error(errorMessage: error.localizedDescription) }
            }
        }
    }
}
