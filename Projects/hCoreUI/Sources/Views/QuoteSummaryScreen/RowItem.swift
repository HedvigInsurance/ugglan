import SwiftUI
import hCore

struct RowItemSection<T: Identifiable, RowView: View>: View {
    let header: String
    let list: [T]
    let rowBuilder: (T) -> RowView

    var body: some View {
        if !list.isEmpty {
            hSection(list, id: \.id) { item in
                rowBuilder(item)
            }
            .withHeader(title: header)
            .sectionContainerStyle(.transparent)
            .hWithoutHorizontalPadding([.row, .divider])
            .accessibilityElement(children: .combine)
        }
    }
}

struct RowItem: View {
    let displayItem: QuoteDisplayItem

    init(
        displayItem: QuoteDisplayItem
    ) {
        self.displayItem = displayItem
    }

    var body: some View {
        hRow {
            HStack(alignment: .top) {
                hText(displayItem.displayTitle, style: .label)
                Spacer()

                if let oldValue = displayItem.displayValueOld, oldValue != displayItem.displayValue {
                    if #available(iOS 16.0, *) {
                        hText(oldValue)
                            .strikethrough()
                            .accessibilityLabel(L10n.voiceoverCurrentValue + oldValue)
                    } else {
                        hText(oldValue)
                            .foregroundColor(hTextColor.Opaque.tertiary)
                            .accessibilityLabel(L10n.voiceoverCurrentValue + oldValue)
                    }
                }

                hText(displayItem.displayValue, style: .label)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel(
                        displayItem.displayValueOld != nil && displayItem.displayValueOld != displayItem.displayValue
                            ? L10n.voiceoverNewValue + displayItem.displayValue : displayItem.displayValue
                    )
            }
        }
        .verticalPadding(.padding4)
        .foregroundColor(hTextColor.Translucent.secondary)
        .hWithoutDivider
        .accessibilityElement(children: .combine)
    }
}

struct DocumentRowItem: View {
    let document: hPDFDocument

    var body: some View {
        hRow {
            HStack {
                hAttributedTextView(
                    text: AttributedPDF().attributedPDFString(for: document.displayName),
                    useSecondaryColor: true
                )
                .padding(.horizontal, -6)
                Spacer()
                hCoreUIAssets.arrowNorthEast.view
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .foregroundColor(hTextColor.Translucent.secondary)
        }
    }
}
