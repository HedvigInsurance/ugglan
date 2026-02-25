import SwiftUI
import hCore
import hCoreUI

public struct AddonCardView: View {
    let openAddon: () -> Void
    let addon: AddonBanner

    public init(
        openAddon: @escaping () -> Void,
        addon: AddonBanner
    ) {
        self.openAddon = openAddon
        self.addon = addon
    }

    public var body: some View {
        hSection {
            hRow {
                VStack(alignment: .leading, spacing: .padding8) {
                    HStack {
                        hText(addon.titleDisplayName)
                            .accessibilityRemoveTraits(.isButton)
                            .accessibilityAddTraits(.isStaticText)
                        Spacer()
                        if let badge = addon.badges.first {
                            hPill(text: badge, color: .grey)
                                .hFieldSize(.small)
                        }
                    }
                    hText(addon.descriptionDisplayName, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)

                    seePriceButton
                }
            }
        }
        .hWithoutHorizontalPadding([.section])
        .sectionContainerStyle(.opaque)
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadiusL).stroke(hBorderColor.primary, lineWidth: 1)
        )
        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.voiceoverPressTo + L10n.addonFlowSeePriceButton)
    }

    var seePriceButton: some View {
        hButton(
            .small,
            .secondary,
            content: .init(title: L10n.addonFlowSeePriceButton),
            handleSeePrice
        )
        .hButtonTakeFullWidth(true)
    }

    private func handleSeePrice() {
        openAddon()
    }
}

#Preview {
    hSection {
        AddonCardView(
            openAddon: {},
            addon: .init(
                contractIds: [""],
                titleDisplayName: "Travel Plus",
                descriptionDisplayName: "Extended travel insurance with extra coverage for your travels",
                badges: ["Popular"],
                addonType: .travelPlus
            )
        )
    }
    .sectionContainerStyle(.transparent)
}
