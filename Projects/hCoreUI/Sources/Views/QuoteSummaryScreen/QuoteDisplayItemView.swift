import SwiftUI
import hCore

struct QuoteDisplayItemView: View {
    let displayItem: QuoteDisplayItem

    init(
        displayItem: QuoteDisplayItem
    ) {
        self.displayItem = displayItem
    }

    var body: some View {
        hRow {
            HStack(alignment: .top) {
                displayTitleView
                Spacer()
                displayValueView
            }
        }
        .verticalPadding(.padding4)
        .foregroundColor(hTextColor.Opaque.secondary)
        .hWithoutDivider
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var displayTitleView: some View {
        if displayItem.crossDisplayTitle, #available(iOS 16.0, *) {
            hText(displayItem.displayTitle, style: .label)
                .strikethrough()
                .accessibilityLabel(L10n.voiceoverCurrentValue + displayItem.displayTitle)
        } else {
            hText(displayItem.displayTitle, style: .label)
        }
    }

    @ViewBuilder
    private var displayValueView: some View {
        let displayValue = displayItem.displayValue
        if displayItem.crossDisplayTitle, #available(iOS 16.0, *) {
            hText(displayValue, style: .label)
                .strikethrough()
        } else {
            hText(displayValue, style: .label)
        }
    }
}

struct DocumentRowItemView: View {
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
            .foregroundColor(hTextColor.Opaque.secondary)
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
