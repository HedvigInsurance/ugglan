import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellingItem: View {
    @PresentableStore var store: ContractStore
    let crossSell: hGraphQL.CrossSell

    func openEmbark() {
        if let embarkStoryName = crossSell.embarkStoryName {
            store.send(.openCrossSellingEmbark(name: embarkStoryName))
            store.send(.setFocusedCrossSell(focusedCrossSell: crossSell))
        }
    }

    var body: some View {
        SwiftUI.Button {
            if crossSell.info != nil {
                store.send(.openCrossSellingDetail(crossSell: crossSell))
            } else {
                openEmbark()
            }
        } label: {
            CrossSellingCardLabel(crossSell: crossSell) {
                openEmbark()
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
            typeOfContract: "SE_ACCIDENT",
            info: nil
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
            typeOfContract: "SE_ACCIDENT",
            info: nil
        )
    )

    static var previews: some View {
        itemWithImage.previewLayout(.sizeThatFits)
        itemWithoutImage.previewLayout(.sizeThatFits).colorScheme(.dark)
    }
}
