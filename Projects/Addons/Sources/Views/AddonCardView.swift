import SwiftUI
import hCore
import hCoreUI

public struct AddonCardView: View {
    let openAddon: () -> Void
    let addon: AddonModel

    public init(
        openAddon: @escaping () -> Void,
        addon: AddonModel
    ) {
        self.openAddon = openAddon
        self.addon = addon
    }

    public var body: some View {
        hSection {
            hRow {
                VStack(alignment: .leading, spacing: .padding8) {
                    HStack {
                        hText(addon.title)
                        Spacer()
                        hPill(text: addon.tag, color: .green, colorLevel: .one)
                            .hFieldSize(.small)
                    }
                    if let subTitle = addon.description {
                        hText(subTitle, style: .label)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }

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
                id: "id",
                title: "Travel Plus",
                description: "Extended travel insurance with extra coverage for your travels",
                tag: "Popular",
                informationText: "",
                activationDate: Date(),
                options: []
            )
        )
    }
    .sectionContainerStyle(.transparent)
}
