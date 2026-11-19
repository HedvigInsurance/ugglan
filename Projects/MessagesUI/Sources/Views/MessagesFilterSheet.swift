import MessagesCore
import SwiftUI
import hCore
import hCoreUI

/// "Show" sheet for choosing which message type to list. Picking an option applies it and closes the sheet.
struct MessagesFilterSheet: View {
    let selection: InboxFilter
    let onApply: (InboxFilter) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        MessagesSheetLayout(
            title: L10n.MessagesInbox.filterTitle,
            subtitle: L10n.MessagesInbox.filterSubtitle,
            secondaryTitle: L10n.generalCancelButton,
            onSecondary: { dismiss() }
        ) {
            hRadioOptionList(InboxFilter.allCases, id: \.self, spacing: .padding4) { filter in
                hRadioOption(value: filter, selection: applyingSelection, item: .init(title: filter.title))
            }
        }
    }

    /// Shows the current filter as selected; choosing any option applies it at once.
    private var applyingSelection: Binding<InboxFilter?> {
        Binding(
            get: { selection },
            set: { newValue in
                if let newValue {
                    onApply(newValue)
                }
                dismiss()
            }
        )
    }
}

#Preview("Light") {
    Localization.Locale.currentLocale.send(.en_SE)
    return Color.clear
        .sheet(isPresented: .constant(true)) {
            MessagesFilterSheet(selection: .channel(.email)) { _ in }
        }
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    Localization.Locale.currentLocale.send(.en_SE)
    return Color.clear
        .sheet(isPresented: .constant(true)) {
            MessagesFilterSheet(selection: .channel(.email)) { _ in }
        }
        .preferredColorScheme(.dark)
}
