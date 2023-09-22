import Foundation
import Kingfisher
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct CrossSellingItem: View {
    @PresentableStore var store: ContractStore
    let crossSell: hGraphQL.CrossSell

    func openExternal() {
        if let urlString = crossSell.webActionURL, let url = URL(string: urlString) {
            store.send(.openCrossSellingWebUrl(url: url))
        } else {
            store.send(.goToFreeTextChat)
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: crossSell.image)
                .resizable()
                .frame(width: 48, height: 48)
                .aspectRatio(contentMode: .fill)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(crossSell.title, style: .standard).foregroundColor(hTextColorNew.primary)
                    MarqueeText(
                        text: crossSell.description,
                        font: Fonts.fontFor(style: .standardSmall),
                        leftFade: 3,
                        rightFade: 3,
                        startDelay: 2
                    )
                    .foregroundColor(hTextColorNew.secondary)
                }
                Spacer()
                hButton.MediumButton(type: .primaryAlt) {
                    openExternal()
                } content: {
                    hText(L10n.crossSellGetPrice)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
        }
        .onTapGesture {
            openExternal()
            ImpactGenerator.soft()
        }
    }
}

struct CrossSellingItemPreviews: PreviewProvider {
    static var itemWithImage = CrossSellingItem(
        crossSell: .init(
            title: "Accident Insurance",
            description: "From 79 SEK/mo.",
            imageURL: URL(
                string:
                    "https://images.unsplash.com/photo-1599501887769-a945a7e4fece?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8"
            )!,
            blurHash: "LEHV6nWB2yk8pyo0adR*.7kCMdnj",
            typeOfContract: "SE_ACCIDENT",
            infos: [],
            type: .accident
        )
    )
    static var previews: some View {
        itemWithImage.previewLayout(.sizeThatFits)
    }
}
