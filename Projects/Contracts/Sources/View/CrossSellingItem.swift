import Foundation
import Kingfisher
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension View {
    func backgroundImageWithBlurHashFallback(
        imageURL: URL,
        blurHash: String,
        hasLoaded: Binding<Bool>
    ) -> some View {
        self.background(
            KFImage(imageURL, isLoaded: hasLoaded)
                .resizable()
                .opacity(hasLoaded.wrappedValue ? 1 : 0)
                .animation(.easeOut)
                .aspectRatio(contentMode: .fill)
        )
        .background(
            Image(
                uiImage: UIImage(
                    blurHash: blurHash,
                    size: .init(width: 32, height: 32)
                ) ?? UIImage()
            )
            .resizable()
        )
    }
}

struct CrossSellingItem: View {
    @PresentableStore var store: ContractStore
    @State var imageHasLoaded: Bool = false
    let crossSell: hGraphQL.CrossSell

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    hText(crossSell.title, style: .headline)
                    hText(crossSell.description, style: .footnote)
                }
                .foregroundColor(hLabelColor.primary)
                .colorScheme(.dark)
                Spacer()
                hButton.SmallButtonFilled {
                    if let name = crossSell.embarkStoryName {
                        store.send(.openEmbark(name: name))
                    } else {
                        store.send(.goToFreeTextChat)
                    }
                } content: {
                    hText(crossSell.buttonText)
                }
                .hButtonFilledStyle(.overImage)
            }
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            minHeight: 200,
            alignment: .bottom
        )
        .backgroundImageWithBlurHashFallback(
            imageURL: crossSell.imageURL,
            blurHash: crossSell.blurHash,
            hasLoaded: $imageHasLoaded
        )
        .cornerRadius(.defaultCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 24, x: 0, y: 4)
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
            buttonText: "Calculate price",
            embarkStoryName: nil
        )
    )

    static var itemWithoutImage = CrossSellingItem(
        crossSell: .init(
            title: "Accident Insurance",
            description: "From 79 SEK/mo.",
            imageURL: URL(string: "https://hedvig.com/")!,
            blurHash: "LEHV6nWB2yk8pyo0adR*.7kCMdnj",
            buttonText: "Calculate price",
            embarkStoryName: nil
        )
    )

    static var previews: some View {
        itemWithImage.previewLayout(.sizeThatFits)
        itemWithoutImage.previewLayout(.sizeThatFits).colorScheme(.dark)
    }
}
