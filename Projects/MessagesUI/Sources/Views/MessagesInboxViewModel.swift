import AppStateContainer
import Foundation
import MessagesCore
import hCore

@MainActor
@Observable
final class MessagesInboxViewModel {
    @ObservationIgnored private let store: MessagesStore

    var filter: InboxFilter = .all
    /// Nil shows messages from any date.
    var dateRange: InboxDateRange?
    var isFilterSheetPresented = false
    var isDateSheetPresented = false

    init(store: MessagesStore = globalAppStateContainer.get()) {
        self.store = store
    }

    /// What the screen shows; drives the cross-fade between loading, error and content.
    enum Phase: Equatable {
        case loading
        case failed(errorMessage: String)
        case loaded
        /// Loaded, but nothing to show: no messages at all, or none matching the filters.
        case empty
    }

    var phase: Phase {
        switch store.state {
        case .notLoaded, .loading: .loading
        case let .failed(errorMessage): .failed(errorMessage: errorMessage)
        case .loaded: list.isEmpty ? .empty : .loaded
        }
    }

    var list: InboxList {
        InboxList(messages: store.messages, filter: filter, sort: .newestFirst, dateRange: dateRange)
    }

    var hasActiveFilters: Bool {
        filter != .all || dateRange != nil
    }

    var emptyStateTitle: String {
        hasActiveFilters ? L10n.MessagesInbox.emptyFilterTitle : L10n.MessagesInbox.emptyTitle
    }

    func clearFilters() {
        filter = .all
        dateRange = nil
    }

    func applyDateRange(_ range: InboxDateRange?) {
        dateRange = range?.isEmpty == false ? range : nil
    }

    func load() async {
        await store.fetchMessages()
    }
}
