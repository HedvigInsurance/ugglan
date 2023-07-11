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
            Spacer(minLength: 20)
            hCoreUIAssets.arrowForward.view
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
    @PresentableStore var store: ForeverStore
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
            .onDisappear {
                store.send(.hasSeenFebruaryCampaign(value: true))
            }
        }
    }
}
