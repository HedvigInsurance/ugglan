import MessagesCore
import SwiftUI
import hCore
import hCoreUI

/// "Date" sheet with a calendar shown straight away: the first tapped day is the start, the second the end, and the
/// days between are highlighted. A third tap starts a new range. "Clear dates" removes the filter.
struct MessagesDateFilterSheet: View {
    let onApply: (InboxDateRange?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var from: Date?
    @State private var to: Date?

    private let calendar = Calendar.current
    private static let dayComponents: Set<Calendar.Component> = [.calendar, .era, .year, .month, .day]

    init(selection: InboxDateRange?, onApply: @escaping (InboxDateRange?) -> Void) {
        self.onApply = onApply
        _from = State(initialValue: selection?.from)
        _to = State(initialValue: selection?.to)
    }

    var body: some View {
        MessagesSheetLayout(
            title: L10n.MessagesInbox.dateFilter,
            subtitle: L10n.MessagesInbox.dateFilterSubtitle,
            primaryTitle: L10n.MessagesInbox.filterShowResults,
            secondaryTitle: L10n.MessagesInbox.dateClear,
            onPrimary: {
                // A single tapped day filters to just that day.
                onApply(from.map { InboxDateRange(from: $0, to: to ?? $0) })
                dismiss()
            },
            onSecondary: {
                onApply(nil)
                dismiss()
            }
        ) {
            // Bounded by now rather than tomorrow's midnight, which still left tomorrow selectable.
            MultiDatePicker(L10n.MessagesInbox.dateFilter, selection: rangeSelection, in: ..<Date())
                .labelsHidden()
                .tint(hSignalColor.Green.element)
                .frame(maxWidth: .infinity)
        }
    }

    /// Feeds the picker every day in the range so it is highlighted, and turns each tap back into a range edit.
    private var rangeSelection: Binding<Set<DateComponents>> {
        Binding(
            get: { daysInRange },
            set: { newValue in
                let current = daysInRange
                let tapped = newValue.subtracting(current).first ?? current.subtracting(newValue).first
                guard let tapped, let day = calendar.date(from: tapped) else { return }
                select(day)
            }
        )
    }

    private func select(_ day: Date) {
        if let from, to == nil, day >= from {
            to = day
        } else {
            from = day
            to = nil
        }
    }

    private var daysInRange: Set<DateComponents> {
        guard let from else { return [] }
        var days: Set<DateComponents> = []
        var day = calendar.startOfDay(for: from)
        let end = calendar.startOfDay(for: to ?? from)
        while day <= end {
            days.insert(calendar.dateComponents(Self.dayComponents, from: day))
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }
}

#Preview("Light") {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return Color.clear
        .sheet(isPresented: .constant(true)) {
            MessagesDateFilterSheet(selection: nil) { _ in }
        }
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return Color.clear
        .sheet(isPresented: .constant(true)) {
            MessagesDateFilterSheet(selection: nil) { _ in }
        }
        .preferredColorScheme(.dark)
}
