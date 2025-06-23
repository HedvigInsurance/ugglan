import SwiftUI
import hCore
import hCoreUI

struct CrossSellBannerComponent: View {
    var body: some View {
        HStack(alignment: .top, spacing: .padding8) {
            hCoreUIAssets.campaign.view
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(hSignalColor.Green.element)
            hText(L10n.crossSellBannerText, style: .label)
                .foregroundColor(hSignalColor.Green.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .padding10)
        .background(hSignalColor.Green.fill)
        .accessibilityElement(children: .combine)
    }
}
