import SwiftUI
import hCore
import hCoreUI

public struct CrossSellPopUpScreen: View {
    let crossSell: CrossSell

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        ZStack {
            BackgroundView()
                .edgesIgnoringSafeArea(.all)

            VStack {
                bannerView
                    .edgesIgnoringSafeArea(.top)

                hForm {
                    VStack(spacing: .padding16) {
                        hCoreUIAssets.bigPillowAccident.view
                            .resizable()
                            .frame(width: 140, height: 140)

                        VStack {
                            hText(crossSell.title)
                            hText(crossSell.description)
                                .foregroundColor(hTextColor.Translucent.secondary)
                        }
                    }
                }
                .hFormContentPosition(.center)
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: .padding16) {
                            hButton(
                                .large,
                                .primary,
                                content: .init(title: L10n.crossSellButton),
                                {

                                }
                            )

                            hText(L10n.crossSellLabel, style: .finePrint)
                                .foregroundColor(hTextColor.Translucent.secondary)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }

        }
    }

    @ViewBuilder
    private var bannerView: some View {
        HStack(alignment: .top, spacing: .padding8) {
            hCoreUIAssets.campaign.view
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(hSignalColor.Green.element)
            hText(L10n.crossSellBannerText, style: .label)
                .foregroundColor(hSignalColor.Green.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(hSignalColor.Green.fill)
    }
}

#Preview {
    CrossSellPopUpScreen(crossSell: .init(title: "", description: "", type: .accident))
}
