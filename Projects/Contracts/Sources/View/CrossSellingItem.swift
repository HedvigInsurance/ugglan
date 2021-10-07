import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellingCardLabel: View {
    @PresentableStore var store: ContractStore
    let crossSell: hGraphQL.CrossSell
    var didTapButton: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                hText(crossSell.title, style: .headline)
                hText(crossSell.description, style: .footnote)
            }
            .foregroundColor(hLabelColor.primary)
            .colorScheme(.dark)
            Spacer()
            hButton.SmallButtonFilled {
                didTapButton()
            } content: {
                hText(crossSell.buttonText)
            }
            .hButtonFilledStyle(.overImage)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            minHeight: 200,
            alignment: .bottom
        )
    }
}

struct CrossSellingCardButtonStyle: SwiftUI.ButtonStyle {
    let crossSell: hGraphQL.CrossSell

    @ViewBuilder func background(configuration: Configuration) -> some View {
        if configuration.isPressed {
            hOverlayColor.pressed.opacity(0.2)
        } else {
            Color.clear
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(background(configuration: configuration))
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [.black.opacity(0.5), .clear]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .backgroundImageWithBlurHashFallback(
                imageURL: crossSell.imageURL,
                blurHash: crossSell.blurHash
            )
            .cornerRadius(.defaultCornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 24, x: 0, y: 4)
    }
}

struct CrossSellingItem: View {
    @PresentableStore var store: ContractStore
    let crossSell: hGraphQL.CrossSell

    func didTapCard() {
        if let name = crossSell.embarkStoryName {
            store.send(.setFocusedCrossSell(focusedCrossSell: crossSell))
            store.send(.openCrossSellingEmbark(name: name))
        } else {
            store.send(.goToFreeTextChat)
        }
    }

    var body: some View {
        SwiftUI.Button {
            didTapCard()
        } label: {
            CrossSellingCardLabel(crossSell: crossSell) {
                didTapCard()
            }
        }
        .buttonStyle(CrossSellingCardButtonStyle(crossSell: crossSell))
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
            embarkStoryName: nil,
            typeOfContract: "SE_ACCIDENT"
        )
    )

    static var itemWithoutImage = CrossSellingItem(
        crossSell: .init(
            title: "Accident Insurance",
            description: "From 79 SEK/mo.",
            imageURL: URL(string: "https://hedvig.com/")!,
            blurHash: "LEHV6nWB2yk8pyo0adR*.7kCMdnj",
            buttonText: "Calculate price",
            embarkStoryName: nil,
            typeOfContract: "SE_ACCIDENT"
        )
    )

    static var previews: some View {
        itemWithImage.previewLayout(.sizeThatFits)
        itemWithoutImage.previewLayout(.sizeThatFits).colorScheme(.dark)
    }
}
