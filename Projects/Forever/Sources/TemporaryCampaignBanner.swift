import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

struct LavenderButtonStyle: ButtonStyle {
    @hColorBuilder func backgroundColor(configuration: Configuration) -> some hColor {
        if configuration.isPressed {
            hTintColor.lavenderOne
        } else {
            hTintColor.lavenderTwo
        }
    }

    @hColorBuilder func foregroundColor(configuration: Configuration) -> some hColor {
        if configuration.isPressed {
            hLabelColor.primary
        } else {
            hLabelColor.secondary
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            VStack {
                hText(L10n.referralCampaignBannerTitle, style: .callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            hCoreUIAssets.chevronRight.view
                .frame(width: 15, height: 15)
        }
        .foregroundColor(foregroundColor(configuration: configuration))
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(backgroundColor(configuration: configuration))
        .cornerRadius(.defaultCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .stroke(hSeparatorColor.separator, lineWidth: .hairlineWidth)
        )
    }
}

struct TemporaryCampaignBanner: View {
    var onTap: () -> Void

    var body: some View {
        if hAnalyticsExperiment.foreverFebruaryCampaign {
            SwiftUI.Button(
                action: {
                    onTap()
                },
                label: {

                }
            )
            .buttonStyle(LavenderButtonStyle())
            .padding(.top, 5)
            .padding(.bottom, 40)
        }
    }
}
