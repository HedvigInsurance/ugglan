import SwiftUI
import hCore
import hCoreUI

struct Column: View {
    let tier: Tier
    let selectedTier: Tier?
    let perils: [Perils]
    let vm: CompareTierViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .cornerRadiusXS)
                .fill(getColumnColor(for: tier))
                .padding(.horizontal, .padding4)
            VStack(alignment: .center) {
                hText(tier.name, style: .label)
                    .foregroundColor(getTierNameColor(for: tier))
                    .padding(.top, 7)

                hSection(perils, id: \.id) { peril in
                    hRow {
                        getRowIcon(for: peril, tier: tier)
                            .frame(height: .padding40, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .verticalPadding(0)
                    .dividerInsets(.leading, tier == vm.tiers.first ? -200 : 0)
                    .modifier(CompareOnRowTap(currentPeril: peril, vm: vm))
                }
                .hSectionWithoutHorizontalPadding
            }
        }
        .frame(width: 108, alignment: .center)
        .padding(.leading, tier == vm.tiers.first ? .padding4 : 0)

    }

    @hColorBuilder
    private func getColumnColor(for tier: Tier) -> some hColor {
        if tier == selectedTier {
            hHighlightColor.Green.fillOne
        } else {
            hBackgroundColor.clear
        }
    }

    @hColorBuilder
    private func getTierNameColor(for tier: Tier) -> some hColor {
        if tier == vm.selectedTier {
            hTextColor.Opaque.black
        } else {
            hTextColor.Opaque.primary
        }
    }

    private func getRowIcon(for peril: Perils, tier: Tier) -> some View {
        Group {
            if !(peril.isDisabled) {
                Image(
                    uiImage: hCoreUIAssets.checkmark.image
                )
                .resizable()
            } else {
                Image(
                    uiImage: hCoreUIAssets.minus.image
                )
                .resizable()
            }
        }
        .frame(width: 24, height: 24)
        .foregroundColor(getIconColor(for: peril, tier: tier))
    }

    @hColorBuilder
    func getIconColor(for peril: Perils, tier: Tier) -> some hColor {
        if peril.isDisabled {
            hFillColor.Opaque.disabled
        } else if tier == vm.selectedTier {
            hFillColor.Opaque.black
        } else {
            hFillColor.Opaque.primary
        }
    }
}
