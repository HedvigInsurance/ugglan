import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingItem: View {
    let crossSell: CrossSell
    @State private var isCrossSellLoading = false

    func openExternal() {
        Task {
            guard let url = URL(string: crossSell.webActionURL) else { return }
            isCrossSellLoading = true
            await Dependencies.urlOpener.open(url)
            isCrossSellLoading = false
        }
    }

    var body: some View {
        CrossSellRow(
            title: crossSell.title,
            subtitle: crossSell.description,
            buttonTitle: crossSell.buttonTitle,
            variant: .secondary,
            isLoading: isCrossSellLoading,
            pillow: { Pillow(imageUrl: crossSell.imageUrl) }
        ) {
            openExternal()
        }
    }

    struct Pillow: View {
        let imageUrl: URL?
        var body: some View {
            KFImage(imageUrl)
                .placeholder { hCoreUIAssets.bigPillowHome.view.resizable() }
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

#Preview {
    CrossSellingItem(
        crossSell: .init(
            id: "id",
            title: "Accident Insurance",
            description: "From 79 SEK/mo.",
            buttonTitle: "See price",
            webActionURL: "",
            imageUrl: nil,
            buttonDescription: "button description"
        )
    )
}
