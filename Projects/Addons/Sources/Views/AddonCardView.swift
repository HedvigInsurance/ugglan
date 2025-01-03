import SwiftUI
import hCore
import hCoreUI

public struct AddonCardView: View {
    let openAddon: () -> Void
    let addon: AddonBannerModel
    let multiplier = HFontTextStyle.body1.multiplier

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
                VStack(alignment: .leading, spacing: multiplier != 1 ? .padding16 * multiplier : .padding8) {
                    HStack {
                        hText(addon.titleDisplayName)
                        Spacer()
                        if let badge = addon.badges.first {
                            hPill(text: badge, color: .green, colorLevel: .one)
                                .hFieldSize(.small)
                        }
                    }
                    hText(addon.descriptionDisplayName, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)

                    hButton.SmallButton(type: .secondary) {
                        openAddon()
                    } content: {
                        hText(L10n.addonFlowSeePriceButton)
                    }
                }
            }
        }
        .hSectionWithoutHorizontalPadding
        .sectionContainerStyle(.transparent)
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadiusL).stroke(hBorderColor.primary, lineWidth: 1)
        )
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
                badges: ["Popular"]
            )
        )
    }
    .sectionContainerStyle(.transparent)
}
