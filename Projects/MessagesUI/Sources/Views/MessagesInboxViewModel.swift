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

    var state: LoadState<[InboxMessage]> { store.state }

    var sections: InboxSections {
        InboxSections(messages: store.messages, filter: filter, sort: .newestFirst, dateRange: dateRange)
    }

    var emptyStateTitle: String {
        filter == .all && dateRange == nil ? L10n.MessagesInbox.emptyTitle : L10n.MessagesInbox.emptyFilterTitle
    }

    func applyDateRange(_ range: InboxDateRange?) {
        dateRange = range?.isEmpty == false ? range : nil
    }

    func load() async {
        await store.fetchMessages()
    }

    func open(_ message: InboxMessage) {
        Task { await store.markAsRead(messageId: message.id) }
    }
}
