import SwiftUI
import hCore
import hCoreUI

struct RemoveAddonBottomSheet: View {
    let removeAddonIntent: RemoveAddonIntent
    let action: (() -> Void)?
    let dismiss: (() -> Void)?

    init(
        removeAddonIntent: RemoveAddonIntent,
        dismiss: @escaping () -> Void,
        action: (() -> Void)? = nil
    ) {
        self.removeAddonIntent = removeAddonIntent
        self.dismiss = dismiss
        self.action = action
    }

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding32) {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(removeAddonIntent.addonDisplayName).foregroundColor(hTextColor.Opaque.primary)
                        hText(
                            action != nil
                                ? L10n.removeAddonDescription
                                : "Du kan bara ta bort det tilläget under förnyelseperiod"  // TODO: localise
                        )
                        .foregroundColor(hTextColor.Translucent.secondary)
                    }

                    VStack(spacing: .padding8) {
                        if let action {
                            hButton(.large, .primary, content: .init(title: L10n.removeAddonButtonTitle), action)
                            hButton(.large, .secondary, content: .init(title: L10n.generalCancelButton)) { dismiss?() }
                        } else {
                            hButton(.large, .secondary, content: .init(title: L10n.generalCloseButton)) { dismiss?() }
                        }
                    }
                }
            }
            .padding(.top, .padding16)
            .padding(.bottom, .padding32)
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
    }
}
