import MessagesCore
import SwiftUI
import hCore
import hCoreUI

/// Navigation bar buttons for the type filter (envelope) and the date filter (calendar). A blue dot marks
/// whichever filter is active.
struct MessagesFilterToolbarButton: View {
    enum Kind {
        case type
        case date
    }

    let kind: Kind
    @Bindable var vm: MessagesInboxViewModel

    var body: some View {
        SwiftUI.Button {
            switch kind {
            case .type: vm.isFilterSheetPresented = true
            case .date: vm.isDateSheetPresented = true
            }
        } label: {
            icon
                .frame(width: .padding24, height: .padding24)
                .foregroundColor(hFillColor.Opaque.primary)
                .overlay(alignment: .topTrailing) {
                    if isActive {
                        ActiveFilterDot()
                            .offset(x: .padding4, y: -.padding2)
                    }
                }
                .accessibilityHidden(true)
                // The bar pads the item to a circle the size of the system back button; the 44 pt height keeps the
                // touch target at the minimum.
                .frame(width: .padding32, height: .padding40 + .padding4)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
    }

    @ViewBuilder
    private var icon: some View {
        switch kind {
        case .type:
            hCoreUIAssets.envelope.view
                .resizable()
                .scaledToFit()
        case .date:
            // The Hedvig UI kit has no calendar icon.
            Image(systemName: "calendar")
                .resizable()
                .scaledToFit()
                .fontWeight(.regular)
        }
    }

    private var isActive: Bool {
        switch kind {
        case .type: vm.filter != .all
        case .date: vm.dateRange != nil
        }
    }

    private var accessibilityLabel: String {
        switch kind {
        case .type: L10n.MessagesInbox.filterSubtitle
        case .date: L10n.MessagesInbox.dateFilter
        }
    }

    private var accessibilityValue: String {
        switch kind {
        case .type: vm.filter.title
        case .date: vm.dateRange?.label ?? ""
        }
    }
}

/// Blue counterpart of the red unread dot on the Home toolbar buttons.
private struct ActiveFilterDot: View {
    var body: some View {
        Circle()
            .fill(hSignalColor.Blue.element)
            .frame(width: 10, height: 10)
            .background {
                Circle()
                    .fill(hBackgroundColor.primary)
                    .frame(width: 12, height: 12)
            }
    }
}
