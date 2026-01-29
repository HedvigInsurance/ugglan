import SwiftUI
import hCore
import hCoreUI

public struct AddonCardView: View {
    let openAddon: () -> Void
    let addon: AddonBannerModel

    public init(
        openAddon: @escaping () -> Void,
        addon: AddonBannerModel
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
                            hPill(text: badge, color: .grey, colorLevel: .three)
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
                type: .travel,
                titleDisplayName: "Travel Plus",
                descriptionDisplayName: "Extended travel insurance with extra coverage for your travels",
                badges: ["Popular"]
            )
        )
    }
    .sectionContainerStyle(.transparent)
}
