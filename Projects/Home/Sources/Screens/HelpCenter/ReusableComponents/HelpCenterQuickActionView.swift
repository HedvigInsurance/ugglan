import SwiftUI
import hCore
import hCoreUI

struct QuickActionView: View {
    let quickAction: QuickAction
    let onQuickAction: () -> Void

    var body: some View {
        hSection {
            hRow {
                VStack(alignment: .leading, spacing: 0) {
                    hText(quickAction.displayTitle)

                    hText(quickAction.displaySubtitle, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                Spacer()
            }
            .withChevronAccessory
            .verticalPadding(.padding12)
            .onTap {
                log.addUserAction(
                    type: .click,
                    name: "help center quick action",
                    attributes: ["action": quickAction.id]
                )
                onQuickAction()
            }
        }
        .hWithoutHorizontalPadding([.section])
        .sectionContainerStyle(.opaque)
    }
}

#Preview {
    QuickActionView(quickAction: .travelInsurance, onQuickAction: {})
}
