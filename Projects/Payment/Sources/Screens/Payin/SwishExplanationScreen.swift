import SwiftUI
import hCore
import hCoreUI

struct SwishExplanationScreen: View {
    @Environment(\.dismiss) private var dismiss
    /// The text beside it scales, so a fixed glyph shrinks away next to it at large sizes.
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 24

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding24) {
                    ForEach(SwishExplanationItem.all) { item in
                        itemView(item)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding24)
        }
        .hFormTitle(title: .init(.navigationLike, .heading1, L10n.paymentSwishExplanationButton))
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hSection {
                hButton(.large, .secondary, content: .init(title: L10n.generalCloseButton)) {
                    dismiss()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private func itemView(_ item: SwishExplanationItem) -> some View {
        HStack(alignment: .top, spacing: .padding12) {
            VStack(alignment: .leading, spacing: .padding2) {
                hText(item.title)
                hText(item.text)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct SwishExplanationItem: Identifiable {
    let id: Int
    let title: String
    let text: String

    @MainActor
    static var all: [SwishExplanationItem] {
        [
            .init(
                id: 1,
                title: L10n.swishExplanationItem1Title,
                text: L10n.swishExplanationItem1Text
            ),
            .init(
                id: 2,
                title: L10n.swishExplanationItem2Title,
                text: L10n.swishExplanationItem2Text
            ),
            .init(
                id: 3,
                title: L10n.swishExplanationItem3Title,
                text: L10n.swishExplanationItem3Text
            ),
        ]
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    return SwishExplanationScreen()
}
