import Kingfisher
import SwiftUI
import hCoreUI

struct CrossSellPillowComponent: View {
    let crossSell: CrossSell

    var body: some View {
        VStack(spacing: .padding16) {
            ZStack(alignment: .topTrailing) {
                KFImage(crossSell.imageUrl)
                    .placeholder {
                        hCoreUIAssets.bigPillowHome.view
                            .resizable()
                            .frame(width: 140, height: 140)
                    }
                    .fade(duration: 0)
                    .resizable()
                if let discountText = crossSell.discountText {
                    hText(discountText, style: .label)
                        .padding(.horizontal, .padding6)
                        .padding(.vertical, .padding3)
                        .background {
                            hHighlightColor.Green.fillOne
                        }
                        .colorScheme(.light)
                        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXS))
                        .offset(x: 9, y: 16)
                }
            }
            .frame(width: 140, height: 140)
            VStack {
                hText(crossSell.title)
                hText(crossSell.description)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CrossSellPillowComponent(
        crossSell: .init(
            id: "id",
            title: "title",
            description: "description",
            discountText: "50%",
            imageUrl: nil,
            buttonDescription: "buttonDescription"
        )
    )
}
