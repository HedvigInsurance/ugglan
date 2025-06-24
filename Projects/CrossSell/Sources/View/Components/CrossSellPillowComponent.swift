import Kingfisher
import SwiftUI
import hCoreUI

struct CrossSellPillowComponent: View {
    let crossSell: CrossSell

    public var body: some View {
        VStack(spacing: .padding16) {
            KFImage(crossSell.imageUrl)
                .placeholder({
                    hCoreUIAssets.bigPillowHome.view
                        .resizable()
                        .frame(width: 140, height: 140)
                })
                .fade(duration: 0)
                .resizable()
                .frame(width: 140, height: 140)
            VStack {
                hText(crossSell.title)
                hText(crossSell.description)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
            .multilineTextAlignment(.center)
        }
    }
}
