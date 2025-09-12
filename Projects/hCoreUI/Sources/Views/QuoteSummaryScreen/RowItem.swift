import SwiftUI
import hCore

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
    let onTap: (hPDFDocument) -> Void

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
        .onTapGesture {
            onTap(document)
        }
        .accessibilityAction {
            onTap(document)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
