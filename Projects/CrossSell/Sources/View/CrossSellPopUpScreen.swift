import SwiftUI
import hCore
import hCoreUI

public struct CrossSellPopUpScreen: View {

    public init() {}

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
                            hText("Accident Insurance")
                            hText("Help when you need it the most")
                                .foregroundColor(hTextColor.Translucent.secondary)
                        }
                    }
                }
                //                .hFormContentPosition(.compact)
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: .padding16) {
                            hButton(
                                .large,
                                .primary,
                                content: .init(title: "Explore insurance"),
                                {

                                }
                            )

                            hText("Easy to use, digital convenience and no lock-in period.", style: .finePrint)
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

//struct GradientBackground: View {
////    let colors: [Color]
//    var body: some View {
//        BackgroundView()
////        LinearGradient(gradient: .init(colors: colors), startPoint: .top, endPoint: .bottom)
//    }
//}

#Preview {
    CrossSellPopUpScreen()
}
